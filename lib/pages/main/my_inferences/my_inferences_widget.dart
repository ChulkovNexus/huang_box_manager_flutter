import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_block.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_state.dart';
import 'package:huang_box_manager_web/util/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class MyInferencesContent extends StatelessWidget {
  const MyInferencesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyInferencesBloc(),
      child: BlocConsumer<MyInferencesBloc, MyInferencesState>(
        listener: (context, state) {
          // Показываем SnackBar при ошибке удаления инференса
          if (state is MyInferencesErrorState && state.error.contains('Failed to delete inference')) {
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
            context.read<MyInferencesBloc>().reloadDataAfterError();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Основное содержимое в зависимости от состояния
              if (state is MyInferencesLoadingState)
                const Center(child: CircularProgressIndicator())
              else if (state is MyInferencesLoadedState)
                state.inferences.isEmpty
                    ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.empty_inferences_list,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(AppLocalizations.of(context)!.inference_name)),
                            DataColumn(label: Text(AppLocalizations.of(context)!.inference_input_price)),
                            DataColumn(label: Text(AppLocalizations.of(context)!.inference_outout_price)),
                            DataColumn(label: Text(AppLocalizations.of(context)!.inference_created_at)),
                            DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
                          ],
                          rows:
                              state.inferences.map((inference) {
                                // Проверяем, находится ли инференс в процессе удаления
                                final isDeleting = state.deletingInferenceIds.containsKey(inference.id);

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
                                    DataCell(
                                      isDeleting
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                          : PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            tooltip: AppLocalizations.of(context)!.actions,
                                            onSelected: (value) {
                                              if (value == 'copy') {
                                                Clipboard.setData(ClipboardData(text: inference.token));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Token скопирован в буфер обмена'),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                );
                                              } else if (value == 'delete') {
                                                // Показываем диалог подтверждения
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext dialogContext) {
                                                    return AlertDialog(
                                                      title: Text(AppLocalizations.of(context)!.confirmation),
                                                      content: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.deleteInferenceConfirmation(inference.inferenceName),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                                          child: Text(AppLocalizations.of(context)!.cancel),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(dialogContext).pop();
                                                            context.read<MyInferencesBloc>().deleteInference(
                                                              inference.id,
                                                            );
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.delete),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                                  PopupMenuItem<String>(
                                                    value: 'copy',
                                                    child: ListTile(
                                                      leading: const Icon(Icons.copy, color: Colors.blue),
                                                      title: const Text(
                                                        'Копировать токен',
                                                        style: TextStyle(color: Colors.blue),
                                                      ),
                                                      contentPadding: EdgeInsets.zero,
                                                      dense: true,
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: ListTile(
                                                      leading: const Icon(Icons.delete, color: Colors.red),
                                                      title: Text(
                                                        AppLocalizations.of(context)!.delete,
                                                        style: const TextStyle(color: Colors.red),
                                                      ),
                                                      contentPadding: EdgeInsets.zero,
                                                      dense: true,
                                                    ),
                                                  ),
                                                ],
                                          ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    )
              else if (state is MyInferencesErrorState)
                Center(child: Text(state.error))
              else
                Center(child: Text(AppLocalizations.of(context)!.myInferences)),

              // Кнопка в правом нижнем углу
              Positioned(
                bottom: 32,
                right: 64,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MainBloc>().selectMenuItem(4);
                  },
                  child: Text(AppLocalizations.of(context)!.addInference, textAlign: TextAlign.center),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
