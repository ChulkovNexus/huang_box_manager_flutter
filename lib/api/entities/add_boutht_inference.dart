enum SortField { input_price, output_price }

enum SortDirection { asc, desc }

class GetInferencesForBuyRequest {
  final String? inferenceName;
  final int page;
  final int pageSize;
  final SortField? sortField;
  final SortDirection? sortDirection;

  GetInferencesForBuyRequest({
    this.inferenceName,
    this.page = 0,
    this.pageSize = 10,
    this.sortField,
    this.sortDirection,
  });

  Map<String, dynamic> toJson() {
    return {
      'inferenceName': inferenceName,
      'page': page,
      'pageSize': pageSize,
      'sortField': sortField?.toString().split('.').last.toUpperCase(),
      'sortDirection': sortDirection?.toString().split('.').last.toUpperCase(),
    };
  }
}

class BuyInferenceRequest {
  final String inferenceId;

  BuyInferenceRequest({required this.inferenceId});

  Map<String, dynamic> toJson() {
    return {'inferenceId': inferenceId};
  }
}
