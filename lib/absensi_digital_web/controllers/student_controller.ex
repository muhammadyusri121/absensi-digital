defmodule AbsensiDigitalWeb.StudentController do
  use AbsensiDigitalWeb, :controller
  alias AbsensiDigital.Student, as: StudentContext
  alias AbsensiDigital.Student.Student

  plug :put_layout, html: {AbsensiDigitalWeb.Layouts, :app}
  plug :assign_student_scope

  defp assign_student_scope(conn, _opts) do
    assign(conn, :current_scope, :student)
  end

  # GET /student
  def index(conn, _params) do
    students = StudentContext.list_students()
    render(conn, :index, students: students)
  end

  # GET /student/new
  def new(conn, _params) do
    changeset = Student.changeset(%Student{}, %{})
    classes = StudentContext.list_classes()
    render(conn, :new, changeset: changeset, classes: classes)
  end

  # POST /student
  def create(conn, %{"student" => student_params}) do
    case StudentContext.create_student(student_params) do
      {:ok, _student} ->
        conn
        |> put_flash(:info, "Siswa berhasil ditambahkan!")
        |> redirect(to: ~p"/student")

      {:error, %Ecto.Changeset{} = changeset} ->
        classes = StudentContext.list_classes()
        render(conn, :new, changeset: changeset, classes: classes)
    end
  end

  # GET /student/:id/edit
  def edit(conn, %{"id" => id}) do
    student = StudentContext.get_student!(id)
    changeset = Student.changeset(student, %{})
    classes = StudentContext.list_classes()
    render(conn, :edit, student: student, changeset: changeset, classes: classes)
  end

  # PUT/PATCH /student/:id
  def update(conn, %{"id" => id, "student" => student_params}) do
    student = StudentContext.get_student!(id)

    case StudentContext.update_student(student, student_params) do
      {:ok, _student} ->
        conn
        |> put_flash(:info, "Data siswa berhasil diperbarui!")
        |> redirect(to: ~p"/student")

      {:error, %Ecto.Changeset{} = changeset} ->
        classes = StudentContext.list_classes()
        render(conn, :edit, student: student, changeset: changeset, classes: classes)
    end
  end

  # DELETE /student/:id
  def delete(conn, %{"id" => id}) do
    student = StudentContext.get_student!(id)
    {:ok, _} = StudentContext.delete_student(student)

    conn
    |> put_flash(:info, "Siswa berhasil dihapus!")
    |> redirect(to: ~p"/student")
  end
end
