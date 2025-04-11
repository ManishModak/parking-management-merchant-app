mixin PaginatedListMixin<T> {
  int get itemsPerPage => 10;

  List<T> getPaginatedItems(List<T> filteredItems, int currentPage) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return endIndex > filteredItems.length
        ? filteredItems.sublist(startIndex)
        : filteredItems.sublist(startIndex, endIndex);
  }

  int getTotalPages(List<T> items) =>
      (items.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();

  void updatePage(int newPage, List<T> filteredItems, void Function(int) setPage) {
    final totalPages = getTotalPages(filteredItems);
    if (newPage < 1 || newPage > totalPages) return;
    setPage(newPage);
  }
}