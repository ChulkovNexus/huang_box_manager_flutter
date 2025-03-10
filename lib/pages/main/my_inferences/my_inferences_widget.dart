import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_block.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/my_inferences_state.dart';
import 'package:huang_box_manager_web/util/constants.dart';
import 'package:intl/intl.dart';

class MyInferencesContent extends StatelessWidget {
  const MyInferencesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyInferencesBloc(),
      child: BlocBuilder<MyInferencesBloc, MyInferencesState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Основное содержимое в зависимости от состояния
              if (state is MyInferencesLoadingState)
                const Center(child: CircularProgressIndicator())
              else if (state is MyInferencesLoadedState)
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text(AppLocalizations.of(context)!.inference_name)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.inference_input_price)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.inference_outout_price)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.inference_created_at)),
                      ],
                      rows:
                          state.inferences.map((inference) {
                            return DataRow(
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
                    context.read<MainBloc>().selectMenuItem(3);
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
