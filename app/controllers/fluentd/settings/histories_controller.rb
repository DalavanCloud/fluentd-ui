class Fluentd::Settings::HistoriesController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :find_backup_file, only: [:show, :reuse, :configtest]

  def index
    @backup_files = @fluentd.agent.backup_files_in_new_order.map do |file_path|
      Fluentd::SettingArchive::BackupFile.new(file_path)
    end
  end

  def show
  end

  def reuse
    @fluentd.agent.config_write @backup_file.content
    redirect_to daemon_setting_path, flash: { success: t('messages.config_successfully_copied',  brand: fluentd_ui_brand) }
  end

  def configtest
    @fluentd.config_file = @backup_file.file_path
    if @fluentd.agent.dryrun
      flash = { success: t('messages.dryrun_is_passed') }
    else
      flash = { danger: @fluentd.agent.log_tail(1).first }
    end
    redirect_to daemon_setting_history_path(params[:id]), flash: flash
  end

  private

  def find_backup_file
    #Do not use BackupFile.new(params[:id]) because params[:id] can be any path.
    @backup_file = Fluentd::SettingArchive::BackupFile.find_by_file_id(@fluentd.agent.config_backup_dir, params[:id])
  end
end
