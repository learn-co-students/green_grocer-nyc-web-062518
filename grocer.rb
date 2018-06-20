require "pry"

def consolidate_cart(cart)
  consolidated_hash = {}
  cart.each do |item_hash|
    item_hash.each do |item, item_details|
      if !consolidated_hash.has_key?(item)
        consolidated_hash[item] = item_details
        consolidated_hash[item][:count] = 1
      else consolidated_hash[item][:count] += 1
      end
    end
  end
  consolidated_hash
end


def apply_coupons(cart, coupons)
  coupon_hash = {}
  cart.each do |item, item_details|
    item_details.each do |label, value|
      coupons.each do |coupon|
        name_with_coupon = "#{item} W/COUPON"
        if item == coupon[:item] && cart[item][:count] >= coupon[:num] && !coupon_hash.include?(name_with_coupon)
          cart[item][:count] -= coupon[:num]
          coupon_hash[name_with_coupon] = {:price => coupon[:cost], :clearance => cart[item][:clearance], :count => 1}
        elsif item == coupon[:item] && cart[item][:count] >= coupon[:num] && coupon_hash.include?(name_with_coupon)
          cart[item][:count] -= coupon[:num]
          coupon_hash[name_with_coupon][:count] += 1
        end
      end
    end
  end

  cart.merge(coupon_hash)
end

def apply_clearance(cart)
  cart.each do |item, item_details|
    if item_details[:clearance] == true
      item_details[:price] = (item_details[:price] * 0.80).round(2)
    end
  end
  cart
end

def checkout(cart, coupons)
  total_cost = 0
  consolidated_cart = consolidate_cart(cart)
  cart_coupons_applied = apply_coupons(consolidated_cart, coupons)
  cart_clearance_applied = apply_clearance(cart_coupons_applied)
  cart_clearance_applied.each do |item, item_details|
    total_item_cost = item_details[:price] * item_details[:count]
    total_cost += total_item_cost
    if total_cost > 100
      total_cost = (total_cost * 0.90).round(2)
    end
  end
  total_cost
end
