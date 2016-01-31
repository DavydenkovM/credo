defmodule Credo.Check.LintAttribute do
  defstruct line: nil,
            meta: nil,      # TODO: remove these
            arguments: nil, # TODO: as they are for debug purposes only
            scope: nil,
            value: nil

  def ignores_issue?(%__MODULE__{value: false} = lint_attribute, issue) do
    (lint_attribute.scope == issue.scope)
  end
  def ignores_issue?(%__MODULE__{value: check_list} = lint_attribute, issue) when is_list(check_list) do
    config = check_in_list(issue.check, check_list)
    if (lint_attribute.scope == issue.scope) do
      case config do
        {check, false} ->
          true
        _ ->
          false
      end
    end
  end
  def ignores_issue?(lint_attribute, issue) do
    false
  end

  defp check_in_list(check, check_list) do
    check_list
    |> Enum.find(&(&1 |> Tuple.to_list |> Enum.at(0) == check ))
  end

  def value_for([false]), do: false
  def value_for([list]) when is_list(list) do
    list |> Enum.map(&value_for/1)
  end
  def value_for({{:__aliases__, _, mod_list}, params}) do
    {Module.concat(mod_list), params}
  end
  def value_for(_), do: nil
end
