import 'dart:async';
import 'dart:io';

import 'package:Ebozor/ui/theme/theme.dart';
import 'package:Ebozor/utils/constant.dart';
import 'package:Ebozor/utils/extensions/extensions.dart';
import 'package:Ebozor/utils/responsiveSize.dart';
import 'package:Ebozor/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapScreen extends StatefulWidget {
  const LocationMapScreen({super.key});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  GoogleMapController? mapController;
  CameraPosition? _cameraPosition;
  final Set<Marker> _markers = {};
  bool _isFetchingLocation = true;
  AddressComponent? formatedAddress;
  double? latitude, longitude;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        latitude = position.latitude;
        longitude = position.longitude;

        _cameraPosition = CameraPosition(
          target: LatLng(latitude!, longitude!),
          zoom: 14.4746,
        );

        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(latitude!, longitude!),
        ));

        getLocationFromLatitudeLongitude(
            latLng: LatLng(latitude!, longitude!));

      }
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isFetchingLocation = false;
    });
  }

  getLocationFromLatitudeLongitude({LatLng? latLng}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latLng?.latitude ?? latitude!,
          latLng?.longitude ?? longitude!);

      if (placemarks.isNotEmpty) {
        Placemark placeMark = placemarks.first;
        formatedAddress = AddressComponent(
            area: placeMark.subLocality,
            areaId: null,
            city: placeMark.locality,
            country: placeMark.country,
            state: placeMark.administrativeArea);
      }
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng newLatLng = LatLng(loc.latitude, loc.longitude);

        mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));

        setState(() {
          latitude = loc.latitude;
          longitude = loc.longitude;
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId('searchedLocation'),
            position: newLatLng,
          ));
        });

        getLocationFromLatitudeLongitude(latLng: newLatLng);
      }
    } catch (e) {
      // Handle invalid address
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevent map resize on keyboard
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.color.borderColor.darken(30))
                ),
                child: BackButton(
                  color: context.color.textDefaultColor,
                )
            )
        ),
      ),
      body: Stack(
        children: [
          // 4) Map as Background (Full Screen)
          _cameraPosition == null
              ? Center(child: UiUtils.progress())
              : GoogleMap(
            initialCameraPosition: _cameraPosition!,
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationButtonEnabled: false, // We use custom buttons
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onTap: (latLng) {
              setState(() {
                _markers.clear();
                _markers.add(Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: latLng,
                ));
                latitude = latLng.latitude;
                longitude = latLng.longitude;
                getLocationFromLatitudeLongitude(latLng: latLng);
              });
            },
          ),

          // 5) Search Bar Overlay over Map
          Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 60, // Space for back button
              right: 16,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: context.color.borderColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5)
                      )
                    ]
                ),
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _searchLocation,
                  decoration: InputDecoration(
                      hintText: "Search location...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.location_on, color: Colors.red), // Red location icon as per hypothesis/reference
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14) // Centered vert
                  ),
                ),
              )
          ),

          // Bottom Buttons
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: context.color.secondaryColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end, // Align Clear All to right? Or center? Reference usually shows Clear All at right top of container or similar.
                  // Requirement: "Above the 'Apply' button, show a text button: 'Clear all'"
                  // Let's put it in a Row with spacer or just aligned right.
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Location",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: context.color.textDefaultColor
                              )
                          ),
                          InkWell(
                            onTap: () {
                              searchController.clear();
                              _getCurrentLocation().then((_) {
                                if(mapController != null && _cameraPosition != null) {
                                  mapController!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
                                }
                              });
                            },
                            child: Text(
                              "Clear All",
                              style: TextStyle(
                                  color: context.color.textLightColor,
                                  fontSize: 12
                              ),
                            ),
                          )
                        ]
                    ),
                    SizedBox(height: 10),
                    if (formatedAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: context.color.territoryColor),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                  [
                                    formatedAddress?.area,
                                    formatedAddress?.city,
                                    formatedAddress?.state,
                                    formatedAddress?.country
                                  ].where((e) => e != null && e.isNotEmpty).join(", "),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: context.color.textDefaultColor,
                                      fontWeight: FontWeight.w600
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                    UiUtils.buildButton(context,
                        onPressed: () {
                          if (formatedAddress != null) {
                            Navigator.pop(context, {
                              'area': formatedAddress!.area,
                              'city': formatedAddress!.city,
                              'state': formatedAddress!.state,
                              'country': formatedAddress!.country,
                              'latitude': latitude,
                              'longitude': longitude
                            });
                          } else {
                            Navigator.pop(context, {
                              'latitude': latitude,
                              'longitude': longitude
                            });
                          }
                        },
                        buttonTitle: "Apply",
                        textColor: context.color.secondaryColor,
                        buttonColor: context.color.territoryColor,
                        radius: 8,
                        height: 45,
                        fontSize: context.font.normal
                    ),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}

class AddressComponent {
  final String? area;
  final int? areaId;
  final String? city;
  final String? state;
  final String? country;

  AddressComponent({this.area, this.areaId, this.city, this.state, this.country});
}
