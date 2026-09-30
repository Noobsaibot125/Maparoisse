import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country.dart';
import '../app_themes.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Color? fillColor;
  final Color? borderColor;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.label,
    this.hintText,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.fillColor,
    this.borderColor,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  void _openCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerBottomSheet(
        currentCountry: widget.selectedCountry,
        onSelect: (country) {
          widget.onCountryChanged(country);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgFillColor = widget.fillColor ?? theme.cardTheme.color;
    final borderCol = widget.borderColor ?? theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bouton Sélecteur Indicatif Pays avec Drapeau ---
            InkWell(
              onTap: _openCountryPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: bgFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.selectedCountry.flag,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.selectedCountry.dialCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // --- Champ Numéro de Téléphone ---
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                ],
                style: TextStyle(color: theme.colorScheme.onSurface),
                validator: widget.validator,
                textInputAction: widget.textInputAction ?? TextInputAction.next,
                onFieldSubmitted: widget.onSubmitted,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? "Ex: 07 00 00 00 00",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: Icon(
                      Icons.phone_outlined,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  filled: true,
                  fillColor: bgFillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderCol),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.errorColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountryPickerBottomSheet extends StatefulWidget {
  final Country currentCountry;
  final ValueChanged<Country> onSelect;

  const _CountryPickerBottomSheet({
    required this.currentCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<_CountryPickerBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Country> _filteredCountries = Country.allCountries;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = Country.allCountries;
      } else {
        _filteredCountries = Country.allCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query) ||
              c.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Barre indicateur drag
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choisir l'indicatif pays",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Rechercher un pays ou un indicatif...",
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                filled: true,
                fillColor: theme.cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      "Aucun pays trouvé",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 20,
                      color: theme.dividerColor.withOpacity(0.5),
                    ),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          country.code == widget.currentCountry.code;

                      return ListTile(
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 26),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country.dialCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        onTap: () => widget.onSelect(country),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
