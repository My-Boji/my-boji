export type ProductCategory = 'car' | 'motorcycle'
export type ProductCondition = 'جديد' | 'مستعمل'
export interface Product {
  id: string
  name: string
  slug: string
  description: string
  category_id: string | null
  category_type: ProductCategory
  make: string
  model: string
  year: string
  price: number
  currency: string
  condition: ProductCondition
  sku: string
  stock_quantity: number
  is_published: boolean
  is_featured: boolean
  image_url: string | null
  images?: string[]
  created_at: string
  updated_at: string
}
