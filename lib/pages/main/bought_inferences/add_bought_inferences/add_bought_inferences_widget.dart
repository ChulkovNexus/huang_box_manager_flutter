import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/add_bought_inferences/add_bought_inferences_bloc.dart';
import 'package:huang_box_manager_web/pages/main/bought_inferences/add_bought_inferences/add_bought_inferences_state.dart';
import 'package:huang_box_manager_web/api/entities/add_boutht_inference.dart';
import 'package:huang_box_manager_web/util/constants.dart';
import 'package:intl/intl.dart';

class AddBoughtInferencesContent extends StatelessWidget {
  const AddBoughtInferencesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddBoughtInferencesBloc(),
      child: BlocConsumer<AddBoughtInferencesBloc, AddBoughtInferencesState>(
        listener: (context, state) {
          // Показываем SnackBar при ошибке покупки инференса
          if (state is AddBoughtInferencesErrorState && state.error.contains('Failed to buy inference')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'ОК',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );

            // Возвращаемся к загрузке данных после показа ошибки
            context.read<AddBoughtInferencesBloc>().reloadDataAfterError();
          }
        },
        builder: (context, state) {
          if (state is AddBoughtInferencesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddBoughtInferencesErrorState && !state.error.contains('Failed to buy inference')) {
            return Center(child: Text(state.error));
          }

          if (state is AddBoughtInferencesLoadedState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Дропбокс для выбора имени инференса
                      SizedBox(
                        width: 500,
                        child: DropdownButton<String>(
                          value: state.selectedInferenceName,
                          hint: Text(AppLocalizations.of(context)!.select_inference),
                          isExpanded: true,
                          items: [
                            ...state.availableInferenceNames.map(
                              (name) => DropdownMenuItem<String>(value: name, child: Text(name)),
                            ),
                          ],
                          onChanged: (value) {
                            context.read<AddBoughtInferencesBloc>().setInferenceName(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(AppLocalizations.of(context)!.inference_name)),
                          DataColumn(
                            label: InkWell(
                              onTap: () {
                                final bloc = context.read<AddBoughtInferencesBloc>();
                                if (state.sortField != 'inputPrice') {
                                  bloc.setSort(SortField.input_price, SortDirection.asc);
                                } else {
                                  bloc.setSort(
                                    SortField.input_price,
                                    state.sortDirection == 'asc' ? SortDirection.desc : SortDirection.asc,
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(AppLocalizations.of(context)!.inference_input_price),
                                  const SizedBox(width: 4),
                                  if (state.sortField == 'inputPrice')
                                    Icon(
                                      state.sortDirection == 'asc' ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  else
                                    const Icon(Icons.unfold_more, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(
                            label: InkWell(
                              onTap: () {
                                final bloc = context.read<AddBoughtInferencesBloc>();
                                if (state.sortField != 'outputPrice') {
                                  bloc.setSort(SortField.output_price, SortDirection.asc);
                                } else {
                                  bloc.setSort(
                                    SortField.output_price,
                                    state.sortDirection == 'asc' ? SortDirection.desc : SortDirection.asc,
                                  );
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(AppLocalizations.of(context)!.inference_outout_price),
                                  const SizedBox(width: 4),
                                  if (state.sortField == 'outputPrice')
                                    Icon(
                                      state.sortDirection == 'asc' ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  else
                                    const Icon(Icons.unfold_more, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          DataColumn(label: Text(AppLocalizations.of(context)!.inference_created_at)),
                          DataColumn(label: Text(AppLocalizations.of(context)!.load)),
                          DataColumn(label: Text(AppLocalizations.of(context)!.owner)),
                          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
                        ],
                        rows:
                            state.inferences.map((inference) {
                              // Проверяем, находится ли инференс в процессе покупки
                              final isBuying = state.buyingInferenceIds.containsKey(inference.id);

                              return DataRow(
                                key: ValueKey(inference.id), // Ключ для анимации
                                cells: [
                                  DataCell(Text(inference.inferenceName)),
                                  DataCell(Text(inference.inputTokenPrice.toString())),
                                  DataCell(Text(inference.outputTokenPrice.toString())),
                                  DataCell(
                                    Text(
                                      DateFormat(
                                        simpleDateFormat,
                                      ).format(DateTime.fromMillisecondsSinceEpoch(inference.createdAt)),
                                    ),
                                  ),
                                  DataCell(Text('${inference.loadPercentage?.toStringAsFixed(2) ?? 0}%')),
                                  DataCell(Text(inference.userName)),
                                  DataCell(
                                    isBuying
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                        : IconButton(
                                          icon: const Icon(Icons.add_circle, size: 20),
                                          tooltip: 'Добавить',
                                          onPressed: () {
                                            context.read<AddBoughtInferencesBloc>().buyInference(inference.id);
                                          },
                                        ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                // Пагинация
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            state.currentPage > 0
                                ? () => context.read<AddBoughtInferencesBloc>().setPage(state.currentPage - 1)
                                : null,
                      ),
                      Text('${state.currentPage + 1}'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            state.hasMorePages
                                ? () => context.read<AddBoughtInferencesBloc>().setPage(state.currentPage + 1)
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
