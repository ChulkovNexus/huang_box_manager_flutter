import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huang_box_manager_web/pages/main/main_block.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/add_inference/new_inference_block.dart';
import 'package:huang_box_manager_web/pages/main/my_inferences/add_inference/new_inference_state.dart';

class AddInferenceContent extends StatelessWidget {
  const AddInferenceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => NewInferencesBloc()..loadInferences(), child: AddInferenceForm());
  }
}

class AddInferenceForm extends StatefulWidget {
  const AddInferenceForm({super.key});

  @override
  _AddInferenceFormState createState() => _AddInferenceFormState();
}

class _AddInferenceFormState extends State<AddInferenceForm> {
  late TextEditingController inferenceController;
  late TextEditingController inputTokenPriceController;
  late TextEditingController outputTokenPriceController;

  @override
  void initState() {
    super.initState();
    inferenceController = TextEditingController();
    inputTokenPriceController = TextEditingController();
    outputTokenPriceController = TextEditingController();

    inferenceController.addListener(() {
      context.read<NewInferencesBloc>().updateForm(
        inference: inferenceController.text,
        inputPrice: inputTokenPriceController.text,
        outputPrice: outputTokenPriceController.text,
      );
    });

    inputTokenPriceController.addListener(() {
      context.read<NewInferencesBloc>().updateForm(
        inference: inferenceController.text,
        inputPrice: inputTokenPriceController.text,
        outputPrice: outputTokenPriceController.text,
      );
    });

    outputTokenPriceController.addListener(() {
      context.read<NewInferencesBloc>().updateForm(
        inference: inferenceController.text,
        inputPrice: inputTokenPriceController.text,
        outputPrice: outputTokenPriceController.text,
      );
    });
  }

  @override
  void dispose() {
    inferenceController.dispose();
    inputTokenPriceController.dispose();
    outputTokenPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            context.read<MainBloc>().selectMenuItem(0);
          },
        ),
        title: Text(AppLocalizations.of(context)!.addInference, style: const TextStyle(color: Colors.blue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<NewInferencesBloc, NewInferenceState>(
        builder: (context, state) {
          if (state is NewInferenceLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NewInferenceLoadedState) {
            return _buildForm(context, state);
          } else if (state is NewInferenceErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is InferenceSeccessfulCreated) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Text(AppLocalizations.of(context)!.inferenceCreated, style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 180),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MainBloc>().selectMenuItem(0);
                    },
                    child: Text(AppLocalizations.of(context)!.great, textAlign: TextAlign.center),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Initial State'));
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, NewInferenceLoadedState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.select_inference),
            items:
                state.availableInferences.map((inference) {
                  return DropdownMenuItem<String>(value: inference, child: Text(inference));
                }).toList(),
            onChanged: (value) {
              inferenceController.text = value ?? '';
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: inputTokenPriceController,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.input_token_price),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: outputTokenPriceController,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.output_token_price),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          ),
          const SizedBox(height: 80),
          BlocBuilder<NewInferencesBloc, NewInferenceState>(
            builder: (context, state) {
              final isFormValid = state is NewInferenceLoadedState && state.isFormValid;
              return ElevatedButton(
                onPressed:
                    isFormValid
                        ? () {
                          context.read<NewInferencesBloc>().createInference();
                        }
                        : null,
                child: Text(AppLocalizations.of(context)!.create),
              );
            },
          ),
        ],
      ),
    );
  }
}
