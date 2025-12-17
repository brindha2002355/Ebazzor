import 'package:Ebozor/ui/theme/theme.dart';
import 'package:Ebozor/utils/extensions/extensions.dart';
import 'package:Ebozor/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import 'package:Ebozor/app/routes.dart';
import 'package:Ebozor/utils/app_icon.dart';
import 'package:Ebozor/utils/ui_utils.dart';
import 'package:Ebozor/ui/screens/home/home_screen.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
          padding: EdgeInsetsDirectional.only(start: 16.0,end: 16),
          child: UiUtils.getSvg(AppIcons.search,
              color: context.color.territoryColor));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding, vertical: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pushNamed(context, Routes.searchScreenRoute,
              arguments: {"autoFocus": true, });
        },
        child: AbsorbPointer(
          absorbing: true,
          child: Row(
            children: [
              Flexible(
                child: Container(
                    width: context.screenWidth,
                    height: 56.rh(
                      context,
                    ),
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: context.color.borderColor.darken(30)),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: context.color.secondaryColor),
                    child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none, //OutlineInputBorder()
                          fillColor: Theme.of(context).colorScheme.secondaryColor,
                          hintText:
                             "searchHintLbl".translate(context),
                          hintStyle: TextStyle(color: context.color.textDefaultColor.withOpacity(0.5)),
                          prefixIcon: buildSearchIcon(),
                          prefixIconConstraints:
                              const BoxConstraints(minHeight: 5, minWidth: 5),
                        ),
                        enableSuggestions: true,
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        onTap: () {
                          //change prefix icon color to primary
                        })),
              ),
              

           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8),
             child: UiUtils.getSvg(AppIcons.notification,color: Colors.grey),
           ),
            // IconButton(onPressed: (){}, icon: Icon(Icons.notifications))
            ],


            
          ),
        ),
      ),
    );
  }
}
