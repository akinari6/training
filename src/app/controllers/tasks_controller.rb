# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :require_login
  before_action :set_task, only: %i[show edit update destroy complete reopen]

  def index
    @tasks = current_user.tasks.order(due_at: :asc)
    respond_to do |format|
      format.html
      format.json { render json: @tasks }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      respond_to do |format|
        format.html { redirect_to @task, notice: "タスクを作成しました" }
        format.json { render json: @task, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.html { redirect_to @task, notice: "タスクを更新しました" }
        format.json { render json: @task, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "タスクを削除しました" }
      format.json { head :no_content }
    end
  end

  def complete
    if @task.update(completed: true)
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "タスクを完了しました" }
        format.json { render json: @task, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to tasks_path, alert: "タスクの更新に失敗しました" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def reopen
    if @task.update(completed: false)
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "タスクを再開しました" }
        format.json { render json: @task, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to tasks_path, alert: "タスクの更新に失敗しました" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_at, :priority, :completed)
  end
end
