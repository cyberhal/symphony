defmodule SymphonyElixir.IssueFilter do
  @moduledoc """
  Evaluates configured issue filters against normalized tracker issues.
  """

  alias SymphonyElixir.Config.Schema.{Filters, LabelFilters}
  alias SymphonyElixir.Linear.Issue

  @spec eligible?(Issue.t(), Filters.t() | nil) :: boolean()
  def eligible?(%Issue{} = issue, %Filters{labels: %LabelFilters{} = labels}) do
    labels_allowed?(Issue.label_names(issue), labels)
  end

  def eligible?(%Issue{}, _filters), do: true

  @spec labels_allowed?([String.t()], LabelFilters.t()) :: boolean()
  def labels_allowed?(issue_labels, %LabelFilters{} = filters) when is_list(issue_labels) do
    issue_label_set = issue_labels |> normalize_labels() |> MapSet.new()
    whitelist = MapSet.new(filters.whitelist)
    blacklist = MapSet.new(filters.blacklist)

    whitelist_matches?(issue_label_set, whitelist) and
      not blacklist_matches?(issue_label_set, blacklist)
  end

  def labels_allowed?(_issue_labels, %LabelFilters{} = filters) do
    labels_allowed?([], filters)
  end

  defp whitelist_matches?(issue_labels, whitelist) do
    MapSet.size(whitelist) == 0 or not MapSet.disjoint?(issue_labels, whitelist)
  end

  defp blacklist_matches?(issue_labels, blacklist) do
    not MapSet.disjoint?(issue_labels, blacklist)
  end

  defp normalize_labels(labels) do
    labels
    |> Enum.map(&normalize_label/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp normalize_label(label) when is_binary(label) do
    label
    |> String.trim()
    |> String.downcase()
  end

  defp normalize_label(label), do: label |> to_string() |> normalize_label()
end
