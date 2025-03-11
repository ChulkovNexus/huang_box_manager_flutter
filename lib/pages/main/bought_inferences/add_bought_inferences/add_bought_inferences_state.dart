import 'package:equatable/equatable.dart';
import 'package:huang_box_manager_web/api/entities/bought_inference.dart';
import 'package:huang_box_manager_web/api/entities/inference.dart';

abstract class AddBoughtInferencesState extends Equatable {
  const AddBoughtInferencesState();

  @override
  List<Object?> get props => [];
}

class AddBoughtInferencesInitialState extends AddBoughtInferencesState {
  const AddBoughtInferencesInitialState();
}

class AddBoughtInferencesLoadingState extends AddBoughtInferencesState {
  const AddBoughtInferencesLoadingState();
}

class AddBoughtInferencesLoadedState extends AddBoughtInferencesState {
  final List<Inference> inferences;
  final List<String> availableInferenceNames;
  final int currentPage;
  final String? selectedInferenceName;
  final String? sortField;
  final String? sortDirection;
  final bool hasMorePages;
  final Map<String, bool> buyingInferenceIds;

  const AddBoughtInferencesLoadedState({
    required this.inferences,
    required this.availableInferenceNames,
    required this.currentPage,
    required this.hasMorePages,
    this.selectedInferenceName,
    this.sortField,
    this.sortDirection,
    this.buyingInferenceIds = const {},
  });

  @override
  List<Object?> get props => [
    inferences,
    availableInferenceNames,
    currentPage,
    hasMorePages,
    selectedInferenceName,
    sortField,
    sortDirection,
    buyingInferenceIds,
  ];

  AddBoughtInferencesLoadedState copyWith({
    List<Inference>? inferences,
    List<String>? availableInferenceNames,
    int? currentPage,
    bool? hasMorePages,
    String? selectedInferenceName,
    String? sortField,
    String? sortDirection,
    Map<String, bool>? buyingInferenceIds,
  }) {
    return AddBoughtInferencesLoadedState(
      inferences: inferences ?? this.inferences,
      availableInferenceNames: availableInferenceNames ?? this.availableInferenceNames,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      selectedInferenceName: selectedInferenceName ?? this.selectedInferenceName,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
      buyingInferenceIds: buyingInferenceIds ?? this.buyingInferenceIds,
    );
  }
}

class AddBoughtInferencesErrorState extends AddBoughtInferencesState {
  final String error;

  const AddBoughtInferencesErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
