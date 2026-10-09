import { apiClient } from '../../core/api/client'
import type { FoodCategory, FoodItem, FoodSource } from './types'

interface Page<T>{content:T[]}
interface FoodDto {id:number;name:string;slug:string;category:string;servingAmount:number;servingUnit:string;gramsPerServing:number|null;caloriesPerServing:number;proteinGPerServing:number;carbsGPerServing:number;fatGPerServing:number;dataSource:string|null;sourceNote:string|null;estimated:boolean;visibility:string;version:number;updatedAt:string}
const categories = new Set(['meat','seafood','dairy','carbs','vegetable','fruit','spice'])
const sources = new Set(['usda','vn_nin','viegym','custom'])
const map=(x:FoodDto):FoodItem=>({id:String(x.id),code:`FD-${String(x.id).padStart(4,'0')}`,nameVi:x.name,nameEn:x.name,category:(categories.has(x.category.toLowerCase())?x.category.toLowerCase():'meat') as FoodCategory,servingSize:Number(x.gramsPerServing??x.servingAmount),servingUnit:`${x.servingAmount} ${x.servingUnit}`,nutrients:{calories:Number(x.caloriesPerServing),protein:Number(x.proteinGPerServing),carbs:Number(x.carbsGPerServing),fat:Number(x.fatGPerServing)},source:(sources.has((x.dataSource??'custom').toLowerCase())?(x.dataSource??'custom').toLowerCase():'custom') as FoodSource,sourceLabel:x.dataSource??'Tùy biến',status:x.visibility==='HIDDEN'?'hidden':'active',image:'',aiNotes:x.sourceNote??undefined,updatedAt:new Date(x.updatedAt).toLocaleString('vi-VN'),version:x.version,slug:x.slug,servingAmount:Number(x.servingAmount),servingUnitRaw:x.servingUnit})
const payload=(x:FoodItem)=>({name:x.nameVi,slug:x.slug??x.nameEn.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,''),category:x.category,servingAmount:x.servingAmount??1,servingUnit:(x.servingUnitRaw??x.servingUnit)||'phần',gramsPerServing:x.servingSize,caloriesPerServing:x.nutrients.calories,proteinGPerServing:x.nutrients.protein,carbsGPerServing:x.nutrients.carbs,fatGPerServing:x.nutrients.fat,dataSource:x.source,sourceNote:x.aiNotes,estimated:true,visibility:x.status==='hidden'?'HIDDEN':'PUBLIC',version:x.version})
export const foodApi={
  async list(){const page=await apiClient<Page<FoodDto>>('/admin/foods?size=500');return page.content.map(map)},
  async save(item:FoodItem){const editing=/^\d+$/.test(item.id);return map(await apiClient<FoodDto>(editing?`/admin/foods/${item.id}`:'/admin/foods',{method:editing?'PUT':'POST',csrfRequired:true,body:JSON.stringify(payload(item))}))},
  async visibility(item:FoodItem){return map(await apiClient<FoodDto>(`/admin/foods/${item.id}/visibility`,{method:'PATCH',csrfRequired:true,body:JSON.stringify({visibility:item.status==='hidden'?'PUBLIC':'HIDDEN',version:item.version})}))},
  async remove(id:string){await apiClient(`/admin/foods/${id}`,{method:'DELETE',csrfRequired:true})},
}
