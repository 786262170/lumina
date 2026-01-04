#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Lumina 图标生成脚本
使用PIL/Pillow生成PNG图标
"""

from PIL import Image, ImageDraw, ImageFont
import os

# 确保输出目录存在
output_dir = os.path.dirname(os.path.abspath(__file__))

def create_lumina_logo(size=80):
    """创建Lumina主Logo - 使用应用图标文件（从AppScope复制）"""
    # 这个文件应该直接从AppScope复制，不需要生成
    print(f"[SKIP] lumina_logo.png should be copied from AppScope/resources/base/media/foreground.png")
    pass

def create_questionnaire_logo(size=80):
    """创建问卷页面主图标 - 表单/问卷图标"""
    print(f"Generating icon_questionnaire.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 紫色渐变圆形背景
    center = size // 2
    radius = size // 2
    draw.ellipse([0, 0, size, size], fill=(102, 126, 234, 255))  # #667eea
    
    # 绘制表单/问卷图标（三个层叠的矩形，代表表单）
    form_w = int(size * 0.4)
    form_h = int(size * 0.3)
    form_x = center - form_w // 2
    form_y = center - form_h // 2
    
    # 底层表单（偏移）
    offset = int(size * 0.05)
    draw.rounded_rectangle([form_x + offset, form_y + offset, form_x + form_w + offset, form_y + form_h + offset], 
                          radius=2, fill=(255, 255, 255, 153))  # 60%透明度
    
    # 中层表单
    draw.rounded_rectangle([form_x, form_y, form_x + form_w, form_y + form_h], 
                          radius=2, fill=(255, 255, 255, 204))  # 80%透明度
    
    # 顶层表单（偏移）
    draw.rounded_rectangle([form_x - offset, form_y - offset, form_x + form_w - offset, form_y + form_h - offset], 
                          radius=2, fill=(255, 255, 255, 255))  # 100%透明度
    
    # 绘制表单上的线条（代表问题）
    line_y1 = form_y - offset + int(form_h * 0.25)
    line_y2 = form_y - offset + int(form_h * 0.5)
    line_y3 = form_y - offset + int(form_h * 0.75)
    line_x_start = form_x - offset + int(form_w * 0.15)
    line_x_end = form_x - offset + form_w - int(form_w * 0.15)
    
    draw.line([line_x_start, line_y1, line_x_end, line_y1], fill=(102, 126, 234, 255), width=2)
    draw.line([line_x_start, line_y2, line_x_end, line_y2], fill=(102, 126, 234, 255), width=2)
    draw.line([line_x_start, line_y3, line_x_end * 0.7, line_y3], fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_questionnaire.png'), 'PNG')
    print(f"[OK] icon_questionnaire.png generated")

def create_recommendation_logo(size=80):
    """创建推荐页面主图标 - 星星+推荐标记"""
    print(f"Generating icon_recommendation.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 紫色渐变圆形背景
    center = size // 2
    radius = size // 2
    draw.ellipse([0, 0, size, size], fill=(102, 126, 234, 255))  # #667eea
    
    # 绘制星星（推荐标记）
    import math
    star_center_x = center
    star_center_y = center - int(size * 0.1)
    outer_radius = int(size * 0.25)
    inner_radius = int(size * 0.1)
    
    points = []
    for i in range(10):
        angle = (math.pi / 5) * i - math.pi / 2
        if i % 2 == 0:
            r = outer_radius
        else:
            r = inner_radius
        x = star_center_x + r * math.cos(angle)
        y = star_center_y + r * math.sin(angle)
        points.append((x, y))
    
    draw.polygon(points, fill=(255, 255, 255, 255))
    
    # 绘制推荐标签（底部）
    tag_w = int(size * 0.35)
    tag_h = int(size * 0.15)
    tag_x = center - tag_w // 2
    tag_y = center + int(size * 0.15)
    draw.rounded_rectangle([tag_x, tag_y, tag_x + tag_w, tag_y + tag_h], 
                          radius=3, fill=(255, 255, 255, 255))
    
    # 标签上的对勾
    check_x1 = tag_x + int(tag_w * 0.25)
    check_y1 = tag_y + tag_h // 2
    check_x2 = tag_x + int(tag_w * 0.4)
    check_y2 = tag_y + int(tag_h * 0.7)
    check_x3 = tag_x + int(tag_w * 0.75)
    check_y3 = tag_y + int(tag_h * 0.3)
    
    draw.line([check_x1, check_y1, check_x2, check_y2], fill=(102, 126, 234, 255), width=3)
    draw.line([check_x2, check_y2, check_x3, check_y3], fill=(102, 126, 234, 255), width=3)
    
    img.save(os.path.join(output_dir, 'icon_recommendation.png'), 'PNG')
    print(f"[OK] icon_recommendation.png generated")

def create_cutout_icon(size=48):
    """创建智能抠图图标 - 剪刀+图片轮廓"""
    print(f"Generating icon_cutout.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 图片轮廓（圆角矩形）
    rect_x = int(size * 0.15)
    rect_y = int(size * 0.25)
    rect_w = int(size * 0.5)
    rect_h = int(size * 0.5)
    draw.rounded_rectangle([rect_x, rect_y, rect_x + rect_w, rect_y + rect_h], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 剪刀（交叉线）
    center_x = int(size * 0.33)
    center_y = int(size * 0.42)
    offset = int(size * 0.1)
    draw.line([center_x - offset, center_y - offset, center_x + offset, center_y + offset], 
              fill=(102, 126, 234, 255), width=2)
    draw.line([center_x + offset, center_y - offset, center_x - offset, center_y + offset], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_cutout.png'), 'PNG')
    print(f"[OK] icon_cutout.png generated")

def create_background_icon(size=48):
    """创建背景替换图标 - 层叠图片+箭头"""
    print(f"Generating icon_background.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 底层图片（30%透明度）
    rect1_x = int(size * 0.15)
    rect1_y = int(size * 0.33)
    rect1_w = int(size * 0.42)
    rect1_h = int(size * 0.42)
    draw.rounded_rectangle([rect1_x, rect1_y, rect1_x + rect1_w, rect1_y + rect1_h], 
                          radius=2, fill=(102, 126, 234, 76))  # 30%透明度
    
    # 顶层图片（80%透明度）
    rect2_x = int(size * 0.33)
    rect2_y = int(size * 0.15)
    rect2_w = int(size * 0.42)
    rect2_h = int(size * 0.42)
    draw.rounded_rectangle([rect2_x, rect2_y, rect2_x + rect2_w, rect2_y + rect2_h], 
                          radius=2, fill=(102, 126, 234, 204))  # 80%透明度
    
    # 箭头
    arrow_x = size // 2
    arrow_y = size // 2
    arrow_len = int(size * 0.15)
    # 箭头线
    draw.line([arrow_x, arrow_y, arrow_x + arrow_len, arrow_y - arrow_len], 
              fill=(102, 126, 234, 255), width=2)
    # 箭头头部
    draw.line([arrow_x + arrow_len, arrow_y - arrow_len, arrow_x + arrow_len - 3, arrow_y - arrow_len], 
              fill=(102, 126, 234, 255), width=2)
    draw.line([arrow_x + arrow_len, arrow_y - arrow_len, arrow_x + arrow_len, arrow_y - arrow_len + 3], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_background.png'), 'PNG')
    print(f"[OK] icon_background.png generated")

def create_light_icon(size=48):
    """创建光效调整图标 - 太阳/光线"""
    print(f"Generating icon_light.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center_x = size // 2
    center_y = size // 2
    radius = int(size * 0.17)
    
    # 中心圆圈（太阳）
    draw.ellipse([center_x - radius, center_y - radius, center_x + radius, center_y + radius], 
                fill=(102, 126, 234, 255))
    
    # 8条光线
    ray_length = int(size * 0.15)
    ray_width = 2
    
    # 上下左右
    rays = [
        (center_x, int(size * 0.1), center_x, int(size * 0.1) + ray_length),  # 上
        (center_x, int(size * 0.9), center_x, int(size * 0.9) - ray_length),  # 下
        (int(size * 0.1), center_y, int(size * 0.1) + ray_length, center_y),  # 左
        (int(size * 0.9), center_y, int(size * 0.9) - ray_length, center_y),  # 右
    ]
    
    # 对角线
    diag_offset = int(size * 0.15)
    rays.extend([
        (center_x - diag_offset, center_y - diag_offset, 
         center_x - diag_offset + int(ray_length * 0.7), center_y - diag_offset + int(ray_length * 0.7)),
        (center_x + diag_offset, center_y + diag_offset, 
         center_x + diag_offset - int(ray_length * 0.7), center_y + diag_offset - int(ray_length * 0.7)),
        (center_x - diag_offset, center_y + diag_offset, 
         center_x - diag_offset + int(ray_length * 0.7), center_y + diag_offset - int(ray_length * 0.7)),
        (center_x + diag_offset, center_y - diag_offset, 
         center_x + diag_offset - int(ray_length * 0.7), center_y - diag_offset + int(ray_length * 0.7)),
    ])
    
    for ray in rays:
        draw.line(ray, fill=(102, 126, 234, 255), width=ray_width)
    
    img.save(os.path.join(output_dir, 'icon_light.png'), 'PNG')
    print(f"[OK] icon_light.png generated")

def create_batch_icon(size=48):
    """创建批量处理图标 - 多个层叠图片"""
    print(f"Generating icon_batch.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 底层图片（40%透明度）
    rect1_x = int(size * 0.15)
    rect1_y = int(size * 0.42)
    rect1_w = int(size * 0.33)
    rect1_h = int(size * 0.33)
    draw.rounded_rectangle([rect1_x, rect1_y, rect1_x + rect1_w, rect1_y + rect1_h], 
                          radius=1, fill=(102, 126, 234, 102))
    
    # 中层图片（60%透明度）
    rect2_x = int(size * 0.25)
    rect2_y = int(size * 0.25)
    rect2_w = int(size * 0.33)
    rect2_h = int(size * 0.33)
    draw.rounded_rectangle([rect2_x, rect2_y, rect2_x + rect2_w, rect2_y + rect2_h], 
                          radius=1, fill=(102, 126, 234, 153))
    
    # 顶层图片（100%透明度）
    rect3_x = int(size * 0.33)
    rect3_y = int(size * 0.08)
    rect3_w = int(size * 0.33)
    rect3_h = int(size * 0.33)
    draw.rounded_rectangle([rect3_x, rect3_y, rect3_x + rect3_w, rect3_y + rect3_h], 
                          radius=1, fill=(102, 126, 234, 255))
    
    # 批量标记（数字3的圆圈）
    mark_x = int(size * 0.58)
    mark_y = int(size * 0.17)
    mark_r = int(size * 0.12)
    draw.ellipse([mark_x - mark_r, mark_y - mark_r, mark_x + mark_r, mark_y + mark_r], 
                fill=(255, 255, 255, 255))
    
    # 数字3（简化：用点表示）
    draw.text((mark_x - 2, mark_y - 4), '3', fill=(102, 126, 234, 255), 
             anchor='mm')
    
    img.save(os.path.join(output_dir, 'icon_batch.png'), 'PNG')
    print(f"[OK] icon_batch.png generated")

def create_scenario_icon(size=48):
    """创建场景图标 - 网格/模板"""
    print(f"Generating icon_scenario.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    padding = int(size * 0.15)
    width = size - padding * 2
    height = size - padding * 2
    
    # 外框
    draw.rounded_rectangle([padding, padding, padding + width, padding + height], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 网格线
    draw.line([size // 2, padding, size // 2, size - padding], 
              fill=(102, 126, 234, 255), width=1)
    draw.line([padding, size // 2, size - padding, size // 2], 
              fill=(102, 126, 234, 255), width=1)
    
    # 四个角的小方块
    small_size = int(size * 0.15)
    corners = [
        (padding + int(size * 0.05), padding + int(size * 0.05)),
        (size - padding - int(size * 0.05) - small_size, padding + int(size * 0.05)),
        (padding + int(size * 0.05), size - padding - int(size * 0.05) - small_size),
        (size - padding - int(size * 0.05) - small_size, size - padding - int(size * 0.05) - small_size),
    ]
    
    for x, y in corners:
        draw.rounded_rectangle([x, y, x + small_size, y + small_size], 
                              radius=1, fill=(102, 126, 234, 153))  # 60%透明度
    
    img.save(os.path.join(output_dir, 'icon_scenario.png'), 'PNG')
    print(f"[OK] icon_scenario.png generated")

def create_star_icon(size=48):
    """创建星标图标 - 四角星"""
    print(f"Generating icon_star.png ({size}x{size})...")
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center_x = size // 2
    center_y = size // 2
    outer_radius = int(size * 0.35)
    inner_radius = int(size * 0.15)
    
    # 绘制四角星
    import math
    points = []
    for i in range(8):  # 4个外点 + 4个内点
        angle = (math.pi / 4) * i - math.pi / 2
        if i % 2 == 0:
            radius = outer_radius
        else:
            radius = inner_radius
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    
    draw.polygon(points, fill=(102, 126, 234, 255))
    
    # 小星星装饰
    small_r = int(size * 0.04)
    decorations = [
        (int(size * 0.25), int(size * 0.25)),
        (int(size * 0.75), int(size * 0.25)),
        (int(size * 0.25), int(size * 0.75)),
        (int(size * 0.75), int(size * 0.75)),
    ]
    
    for x, y in decorations:
        draw.ellipse([x - small_r, y - small_r, x + small_r, y + small_r], 
                    fill=(255, 255, 255, 204))  # 80%透明度白色
    
    img.save(os.path.join(output_dir, 'icon_star.png'), 'PNG')
    print(f"[OK] icon_star.png generated")

def create_bag_icon(size=48):
    """创建购物袋图标"""
    print(f"Generating icon_bag.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 购物袋主体
    bag_w, bag_h = int(size * 0.5), int(size * 0.5)
    bag_x = center_x - bag_w // 2
    bag_y = center_y - bag_h // 2 + int(size * 0.05)
    
    # 提手
    handle_w = int(size * 0.2)
    handle_h = int(size * 0.08)
    handle_x = center_x - handle_w // 2
    handle_y = bag_y - handle_h
    draw.arc([handle_x, handle_y, handle_x + handle_w, handle_y + handle_h * 2], 
             start=0, end=180, fill=(102, 126, 234, 255), width=2)
    
    # 袋身
    draw.rounded_rectangle([bag_x, bag_y, bag_x + bag_w, bag_y + bag_h], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 底部横线
    draw.line([bag_x + int(size * 0.1), bag_y + bag_h, bag_x + bag_w - int(size * 0.1), bag_y + bag_h], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_bag.png'), 'PNG')
    print(f"[OK] icon_bag.png generated")

def create_phone_icon(size=48):
    """创建手机图标"""
    print(f"Generating icon_phone.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 手机外框
    phone_w, phone_h = int(size * 0.4), int(size * 0.6)
    phone_x = center_x - phone_w // 2
    phone_y = center_y - phone_h // 2
    draw.rounded_rectangle([phone_x, phone_y, phone_x + phone_w, phone_y + phone_h], 
                          radius=3, outline=(102, 126, 234, 255), width=2)
    
    # 屏幕
    screen_w, screen_h = int(size * 0.3), int(size * 0.4)
    screen_x = center_x - screen_w // 2
    screen_y = phone_y + int(size * 0.08)
    draw.rounded_rectangle([screen_x, screen_y, screen_x + screen_w, screen_y + screen_h], 
                          radius=1, fill=(102, 126, 234, 51))
    
    # 底部按钮
    btn_y = phone_y + phone_h - int(size * 0.08)
    draw.ellipse([center_x - 3, btn_y - 2, center_x + 3, btn_y + 2], 
                fill=(102, 126, 234, 255))
    
    img.save(os.path.join(output_dir, 'icon_phone.png'), 'PNG')
    print(f"[OK] icon_phone.png generated")

def create_cosmetic_icon(size=48):
    """创建化妆品图标 - 圆形瓶子"""
    print(f"Generating icon_cosmetic.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 圆形瓶子
    radius = int(size * 0.25)
    draw.ellipse([center_x - radius, center_y - radius, center_x + radius, center_y + radius], 
                outline=(102, 126, 234, 255), width=2)
    
    # 盖子
    cap_w, cap_h = int(size * 0.2), int(size * 0.1)
    cap_x = center_x - cap_w // 2
    cap_y = center_y - radius - cap_h
    draw.rounded_rectangle([cap_x, cap_y, cap_x + cap_w, cap_y + cap_h], 
                          radius=2, fill=(102, 126, 234, 255))
    
    img.save(os.path.join(output_dir, 'icon_cosmetic.png'), 'PNG')
    print(f"[OK] icon_cosmetic.png generated")

def create_food_icon(size=48):
    """创建食物图标 - 圆形带点"""
    print(f"Generating icon_food.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 圆形
    radius = int(size * 0.25)
    draw.ellipse([center_x - radius, center_y - radius, center_x + radius, center_y + radius], 
                fill=(102, 126, 234, 255))
    
    # 中心点
    dot_r = int(size * 0.08)
    draw.ellipse([center_x - dot_r, center_y - dot_r, center_x + dot_r, center_y + dot_r], 
                fill=(255, 255, 255, 255))
    
    img.save(os.path.join(output_dir, 'icon_food.png'), 'PNG')
    print(f"[OK] icon_food.png generated")

def create_home_icon(size=48):
    """创建家居图标 - 房子"""
    print(f"Generating icon_home.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 屋顶（三角形）
    roof_size = int(size * 0.3)
    roof_points = [
        (center_x, center_y - roof_size),
        (center_x - roof_size, center_y),
        (center_x + roof_size, center_y)
    ]
    draw.polygon(roof_points, outline=(102, 126, 234, 255), width=2)
    
    # 房身（矩形）
    house_w, house_h = int(size * 0.4), int(size * 0.3)
    house_x = center_x - house_w // 2
    house_y = center_y
    draw.rounded_rectangle([house_x, house_y, house_x + house_w, house_y + house_h], 
                          radius=1, outline=(102, 126, 234, 255), width=2)
    
    # 门
    door_w, door_h = int(size * 0.12), int(size * 0.15)
    door_x = center_x - door_w // 2
    door_y = house_y + house_h - door_h
    draw.rounded_rectangle([door_x, door_y, door_x + door_w, door_y + door_h], 
                          radius=1, fill=(102, 126, 234, 102))
    
    img.save(os.path.join(output_dir, 'icon_home.png'), 'PNG')
    print(f"[OK] icon_home.png generated")

def create_sports_icon(size=48):
    """创建运动图标 - 圆形"""
    print(f"Generating icon_sports.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 圆形
    radius = int(size * 0.25)
    draw.ellipse([center_x - radius, center_y - radius, center_x + radius, center_y + radius], 
                outline=(102, 126, 234, 255), width=2)
    
    # 内部线条（表示运动）
    line_len = int(size * 0.15)
    draw.line([center_x - line_len, center_y, center_x + line_len, center_y], 
              fill=(102, 126, 234, 255), width=2)
    draw.line([center_x, center_y - line_len, center_x, center_y + line_len], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_sports.png'), 'PNG')
    print(f"[OK] icon_sports.png generated")

def create_book_icon(size=48):
    """创建书本图标"""
    print(f"Generating icon_book.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 书本外框
    book_w, book_h = int(size * 0.5), int(size * 0.35)
    book_x = center_x - book_w // 2
    book_y = center_y - book_h // 2
    draw.rounded_rectangle([book_x, book_y, book_x + book_w, book_y + book_h], 
                          radius=1, outline=(102, 126, 234, 255), width=2)
    
    # 书页分隔线
    draw.line([center_x, book_y, center_x, book_y + book_h], 
              fill=(102, 126, 234, 255), width=1)
    
    img.save(os.path.join(output_dir, 'icon_book.png'), 'PNG')
    print(f"[OK] icon_book.png generated")

def create_other_icon(size=48):
    """创建其他图标 - 三个点"""
    print(f"Generating icon_other.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 三个点
    dot_r = int(size * 0.08)
    dots = [
        (center_x - int(size * 0.15), center_y),
        (center_x, center_y),
        (center_x + int(size * 0.15), center_y)
    ]
    for x, y in dots:
        draw.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r], 
                    fill=(102, 126, 234, 255))
    
    img.save(os.path.join(output_dir, 'icon_other.png'), 'PNG')
    print(f"[OK] icon_other.png generated")

def create_platform_icon(size=48):
    """创建平台图标 - 网格/窗口（通用平台图标）"""
    print(f"Generating icon_platform.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 外框
    frame_w, frame_h = int(size * 0.5), int(size * 0.5)
    frame_x = center_x - frame_w // 2
    frame_y = center_y - frame_h // 2
    draw.rounded_rectangle([frame_x, frame_y, frame_x + frame_w, frame_y + frame_h], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 内部网格
    draw.line([frame_x, center_y, frame_x + frame_w, center_y], 
              fill=(102, 126, 234, 255), width=1)
    draw.line([center_x, frame_y, center_x, frame_y + frame_h], 
              fill=(102, 126, 234, 255), width=1)
    
    img.save(os.path.join(output_dir, 'icon_platform.png'), 'PNG')
    print(f"[OK] icon_platform.png generated")

def create_taobao_icon(size=48):
    """创建淘宝平台图标 - 购物袋"""
    print(f"Generating icon_taobao.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 购物袋主体
    bag_w, bag_h = int(size * 0.5), int(size * 0.5)
    bag_x = center_x - bag_w // 2
    bag_y = center_y - bag_h // 2 + int(size * 0.05)
    
    # 提手
    handle_w = int(size * 0.2)
    handle_h = int(size * 0.08)
    handle_x = center_x - handle_w // 2
    handle_y = bag_y - handle_h
    draw.arc([handle_x, handle_y, handle_x + handle_w, handle_y + handle_h * 2], 
             start=0, end=180, fill=(102, 126, 234, 255), width=2)
    
    # 袋身
    draw.rounded_rectangle([bag_x, bag_y, bag_x + bag_w, bag_y + bag_h], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 底部横线
    draw.line([bag_x + int(size * 0.1), bag_y + bag_h, bag_x + bag_w - int(size * 0.1), bag_y + bag_h], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_taobao.png'), 'PNG')
    print(f"[OK] icon_taobao.png generated")

def create_tmall_icon(size=48):
    """创建天猫平台图标 - 猫头形状"""
    print(f"Generating icon_tmall.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 猫头（圆形+两个三角形耳朵）
    head_radius = int(size * 0.25)
    draw.ellipse([center_x - head_radius, center_y - head_radius, center_x + head_radius, center_y + head_radius], 
                outline=(102, 126, 234, 255), width=2)
    
    # 左耳
    ear1_points = [
        (center_x - head_radius, center_y - head_radius),
        (center_x - int(size * 0.15), center_y - int(size * 0.3)),
        (center_x - int(size * 0.05), center_y - int(size * 0.2))
    ]
    draw.polygon(ear1_points, outline=(102, 126, 234, 255), width=2)
    
    # 右耳
    ear2_points = [
        (center_x + head_radius, center_y - head_radius),
        (center_x + int(size * 0.15), center_y - int(size * 0.3)),
        (center_x + int(size * 0.05), center_y - int(size * 0.2))
    ]
    draw.polygon(ear2_points, outline=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_tmall.png'), 'PNG')
    print(f"[OK] icon_tmall.png generated")

def create_jd_icon(size=48):
    """创建京东平台图标 - 狗头形状"""
    print(f"Generating icon_jd.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 狗头（圆形+两个三角形耳朵）
    head_radius = int(size * 0.25)
    draw.ellipse([center_x - head_radius, center_y - head_radius, center_x + head_radius, center_y + head_radius], 
                outline=(102, 126, 234, 255), width=2)
    
    # 左耳（下垂）
    ear1_points = [
        (center_x - head_radius, center_y - int(size * 0.1)),
        (center_x - int(size * 0.2), center_y - int(size * 0.25)),
        (center_x - int(size * 0.1), center_y - int(size * 0.15))
    ]
    draw.polygon(ear1_points, outline=(102, 126, 234, 255), width=2)
    
    # 右耳（下垂）
    ear2_points = [
        (center_x + head_radius, center_y - int(size * 0.1)),
        (center_x + int(size * 0.2), center_y - int(size * 0.25)),
        (center_x + int(size * 0.1), center_y - int(size * 0.15))
    ]
    draw.polygon(ear2_points, outline=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_jd.png'), 'PNG')
    print(f"[OK] icon_jd.png generated")

def create_douyin_icon(size=48):
    """创建抖音平台图标 - 音符/音乐符号"""
    print(f"Generating icon_douyin.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 音符形状
    # 圆形部分
    note_circle_r = int(size * 0.12)
    note_circle_x = center_x - int(size * 0.1)
    note_circle_y = center_y - int(size * 0.1)
    draw.ellipse([note_circle_x - note_circle_r, note_circle_y - note_circle_r, 
                  note_circle_x + note_circle_r, note_circle_y + note_circle_r], 
                 fill=(102, 126, 234, 255))
    
    # 竖线
    line_x = center_x
    line_y1 = center_y - int(size * 0.25)
    line_y2 = center_y + int(size * 0.25)
    draw.line([line_x, line_y1, line_x, line_y2], fill=(102, 126, 234, 255), width=3)
    
    # 波浪线（代表音波）
    wave_x1 = center_x + int(size * 0.1)
    wave_y = center_y
    wave_x2 = center_x + int(size * 0.3)
    draw.arc([wave_x1, wave_y - int(size * 0.1), wave_x2, wave_y + int(size * 0.1)], 
             start=0, end=180, fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_douyin.png'), 'PNG')
    print(f"[OK] icon_douyin.png generated")

def create_xiaohongshu_icon(size=48):
    """创建小红书平台图标 - 心形"""
    print(f"Generating icon_xiaohongshu.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 心形
    import math
    heart_size = int(size * 0.3)
    # 左半圆
    draw.ellipse([center_x - heart_size, center_y - int(size * 0.15), center_x, center_y + int(size * 0.05)], 
                 outline=(102, 126, 234, 255), width=2)
    # 右半圆
    draw.ellipse([center_x, center_y - int(size * 0.15), center_x + heart_size, center_y + int(size * 0.05)], 
                 outline=(102, 126, 234, 255), width=2)
    # 底部三角形
    heart_points = [
        (center_x, center_y + int(size * 0.05)),
        (center_x - heart_size, center_y + int(size * 0.2)),
        (center_x + heart_size, center_y + int(size * 0.2))
    ]
    draw.polygon(heart_points, outline=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_xiaohongshu.png'), 'PNG')
    print(f"[OK] icon_xiaohongshu.png generated")

def create_amazon_icon(size=48):
    """创建亚马逊平台图标 - 箭头（从A到Z）"""
    print(f"Generating icon_amazon.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 箭头形状（从A到Z的微笑曲线）
    arrow_w = int(size * 0.4)
    arrow_h = int(size * 0.3)
    arrow_x = center_x - arrow_w // 2
    arrow_y = center_y - arrow_h // 2
    
    # 箭头主体（曲线）
    draw.arc([arrow_x, arrow_y, arrow_x + arrow_w, arrow_y + arrow_h], 
             start=0, end=180, fill=(102, 126, 234, 255), width=3)
    
    # 箭头头部
    arrow_head_x = arrow_x + arrow_w
    arrow_head_y = arrow_y + arrow_h // 2
    arrow_points = [
        (arrow_head_x, arrow_head_y),
        (arrow_head_x - int(size * 0.08), arrow_head_y - int(size * 0.06)),
        (arrow_head_x - int(size * 0.08), arrow_head_y + int(size * 0.06))
    ]
    draw.polygon(arrow_points, fill=(102, 126, 234, 255))
    
    img.save(os.path.join(output_dir, 'icon_amazon.png'), 'PNG')
    print(f"[OK] icon_amazon.png generated")

def create_simple_icon(size=48):
    """创建简约现代图标 - 简洁线条六边形"""
    print(f"Generating icon_simple.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    import math
    # 六边形
    radius = int(size * 0.25)
    points = []
    for i in range(6):
        angle = (math.pi / 3) * i - math.pi / 2
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    
    draw.polygon(points, outline=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_simple.png'), 'PNG')
    print(f"[OK] icon_simple.png generated")

def create_professional_icon(size=48):
    """创建专业商务图标 - 方形带十字"""
    print(f"Generating icon_professional.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 方形
    square_size = int(size * 0.4)
    square_x = center_x - square_size // 2
    square_y = center_y - square_size // 2
    draw.rounded_rectangle([square_x, square_y, square_x + square_size, square_y + square_size], 
                          radius=2, outline=(102, 126, 234, 255), width=2)
    
    # 十字线
    line_len = int(size * 0.2)
    draw.line([center_x - line_len, center_y, center_x + line_len, center_y], 
              fill=(102, 126, 234, 255), width=2)
    draw.line([center_x, center_y - line_len, center_x, center_y + line_len], 
              fill=(102, 126, 234, 255), width=2)
    
    img.save(os.path.join(output_dir, 'icon_professional.png'), 'PNG')
    print(f"[OK] icon_professional.png generated")

def create_creative_icon(size=48):
    """创建创意个性图标 - 星形+小点"""
    print(f"Generating icon_creative.png ({size}x{size})...")
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center_x, center_y = size // 2, size // 2
    
    # 星形
    import math
    outer_radius = int(size * 0.25)
    inner_radius = int(size * 0.1)
    points = []
    for i in range(10):
        angle = (math.pi / 5) * i - math.pi / 2
        if i % 2 == 0:
            radius = outer_radius
        else:
            radius = inner_radius
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    
    draw.polygon(points, fill=(102, 126, 234, 255))
    
    # 小装饰点
    dot_r = int(size * 0.04)
    decorations = [
        (center_x - int(size * 0.25), center_y - int(size * 0.1)),
        (center_x + int(size * 0.25), center_y + int(size * 0.1))
    ]
    for x, y in decorations:
        draw.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r], 
                    fill=(255, 255, 255, 255))
    
    img.save(os.path.join(output_dir, 'icon_creative.png'), 'PNG')
    print(f"[OK] icon_creative.png generated")

if __name__ == '__main__':
    print("=" * 50)
    print("Lumina Icon Generator")
    print("=" * 50)
    print()
    
    try:
        # 生成页面主图标
        create_lumina_logo(80)  # 应用logo（从AppScope复制）
        create_questionnaire_logo(80)  # 问卷页面主图标
        create_recommendation_logo(80)  # 推荐页面主图标
        
        # 生成功能图标
        create_cutout_icon(48)
        create_background_icon(48)
        create_light_icon(48)
        create_batch_icon(48)
        create_scenario_icon(48)
        create_star_icon(48)
        
        # 生成选项图标
        create_bag_icon(48)
        create_phone_icon(48)
        create_cosmetic_icon(48)
        create_food_icon(48)
        create_home_icon(48)
        create_sports_icon(48)
        create_book_icon(48)
        create_other_icon(48)
        
        # 生成平台图标（有区分度）
        create_platform_icon(48)  # 通用平台图标
        create_taobao_icon(48)  # 淘宝
        create_tmall_icon(48)  # 天猫
        create_jd_icon(48)  # 京东
        create_douyin_icon(48)  # 抖音
        create_xiaohongshu_icon(48)  # 小红书
        create_amazon_icon(48)  # 亚马逊
        
        # 生成设计风格图标
        create_simple_icon(48)
        create_professional_icon(48)
        create_creative_icon(48)
        
        print()
        print("=" * 50)
        print("All icons generated successfully!")
        print("=" * 50)
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        print("Please install Pillow: pip install Pillow")

