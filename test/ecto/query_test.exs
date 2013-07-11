Code.require_file "../test_helper.exs", __DIR__

defmodule Ecto.QueryTest do
  use ExUnit.Case, async: true

  import Ecto.TestHelpers
  import Ecto.Query

  defmodule PostEntity do
    use Ecto.Entity
    table_name :post_entity

    field :title, :string
  end

  defmodule CommentEntity do
    use Ecto.Entity
    table_name :comments

    field :text, :string
  end

  test "vars are order dependent" do
    query = from(p in PostEntity) |> select([q], q.title)
    validate(query)
  end

  test "can append to selected query" do
    query = from(p in PostEntity) |> select([], 1) |> from(q in PostEntity)
    validate(query)
  end

  test "only one select is allowed" do
    assert_raise ArgumentError, "only one select expression is allowed in query", fn ->
      from(p in PostEntity) |> select([], 1) |> select([], 2)
    end
  end

  test "binding should be list of variables" do
    assert_raise ArgumentError, "binding should be list of variables", fn ->
      delay_compile select([0], 1)
    end
  end

  test "keyword query" do
    # queries need to be on the same line or == wont work

    assert from(p in PostEntity, []) == from(p in PostEntity)

    assert from(p in PostEntity, select: 1+2) == from(p in PostEntity) |> select([p], 1+2)

    assert from(p in PostEntity, where: 1<2) == from(p in PostEntity) |> where([p], 1<2)

    assert from(p in PostEntity, where: true, from: q in PostEntity, select: 1) == from(p in PostEntity) |> where([p], true) |> from(q in PostEntity) |> select([p, q], 1)
  end

  test "variable is already defined" do
    assert_raise ArgumentError, "variable `p` is already defined", fn ->
      delay_compile(from(p in PostEntity, from: p in PostEntity))
    end
  end

  test "extend keyword query" do
    query = from(p in PostEntity)
    assert (query |> select([p], p.title)) == extend(query, [p], select: p.title)
  end
end