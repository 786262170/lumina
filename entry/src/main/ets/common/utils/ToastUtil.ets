/**
 * ============================================
 * LUMINA AI - TOAST UTILITY
 * 统一提示工具类
 * ============================================
 */

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Toast工具类
 * 用于显示成功、失败、警告等信息提示
 */
export class ToastUtil {
  /**
   * 显示成功提示
   * @param message 提示信息
   * @param duration 显示时长（毫秒），默认2000
   */
  static showSuccess(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration,
        bottom: 100
      });
      console.info(`[ToastUtil] 显示成功提示: ${message}`);
    } catch (error) {
      // 如果 showToast 失败，至少输出到控制台
      console.error(`[ToastUtil] 显示提示失败: ${error}`);
      console.info(`[ToastUtil] 提示内容: ${message}`);
    }
  }

  /**
   * 显示错误提示
   * @param message 错误信息
   * @param duration 显示时长（毫秒），默认3000
   */
  static showError(message: string, duration: number = 3000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration,
        bottom: 100
      });
      console.error(`[ToastUtil] 显示错误提示: ${message}`);
    } catch (error) {
      // 如果 showToast 失败，至少输出到控制台
      console.error(`[ToastUtil] 显示提示失败: ${error}`);
      console.error(`[ToastUtil] 错误内容: ${message}`);
    }
  }

  /**
   * 显示警告提示
   * @param message 警告信息
   * @param duration 显示时长（毫秒），默认2000
   */
  static showWarning(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration,
        bottom: 100
      });
      console.warn(`[ToastUtil] 显示警告提示: ${message}`);
    } catch (error) {
      // 如果 showToast 失败，至少输出到控制台
      console.error(`[ToastUtil] 显示提示失败: ${error}`);
      console.warn(`[ToastUtil] 警告内容: ${message}`);
    }
  }

  /**
   * 显示信息提示
   * @param message 提示信息
   * @param duration 显示时长（毫秒），默认2000
   */
  static showInfo(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration,
        bottom: 100
      });
      console.info(`[ToastUtil] 显示信息提示: ${message}`);
    } catch (error) {
      // 如果 showToast 失败，至少输出到控制台
      console.error(`[ToastUtil] 显示提示失败: ${error}`);
      console.info(`[ToastUtil] 信息内容: ${message}`);
    }
  }
}

