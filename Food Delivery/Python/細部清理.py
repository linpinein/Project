import pandas as pd
import emoji # type: ignore

def remove_emoji(text):                                                 # 定義 移除emoji函數，用以移除文字旁的圖示
    return emoji.replace_emoji(text , replace='')                       # 當有emoji時，替換成空字串

##################################################################################################################################################################################################
# 1. 匯入資料
##################################################################################################################################################################################################

Path_1 = r"C:\Users\Lin\OneDrive\Desktop\言\Sideproject\Uber Eats熱門餐廳 特徵分析\excel\原資料庫\TX_Init_Restaurant_Menus.csv"
Path_2 = r"C:\Users\Lin\OneDrive\Desktop\言\Sideproject\Uber Eats熱門餐廳 特徵分析\excel\原資料庫\TX_Init_Restaurant.csv"

TX_Init_Restaurant_Menus = pd.read_csv(Path_1)
TX_Init_Restaurant = pd.read_csv(Path_2)

##################################################################################################################################################################################################
# 2. 清除數據前後空值
##################################################################################################################################################################################################

for i in TX_Init_Restaurant.columns:                                                                # 取這個 DataFrame 的所有columns
    if TX_Init_Restaurant[i].dtype == 'object':                                                     # 如果該 columns 型態為文字
        TX_Init_Restaurant[i] = TX_Init_Restaurant[i].str.strip()                                   # 去除前後空值，避免因前後空白造成統計分類錯誤

for i in TX_Init_Restaurant_Menus.columns:                                                          # 同上
    if TX_Init_Restaurant_Menus[i].dtype == 'object': 
        TX_Init_Restaurant_Menus[i] = TX_Init_Restaurant_Menus[i].str.strip()

##################################################################################################################################################################################################
# 3. 數據文字調整
##################################################################################################################################################################################################
    
for i in TX_Init_Restaurant.columns:                                                                                        # 取這個 DataFrame 的所有columns
    if TX_Init_Restaurant[i].dtype == 'object':                                                                             # 如果該 columns 型態為文字
        TX_Init_Restaurant[i] = TX_Init_Restaurant[i].apply(remove_emoji).str.strip()                                       # 去除emoji，再執行一次去除前後空值，確保數據乾淨、一致性
        
for i in TX_Init_Restaurant_Menus.columns:                                                                                  # 同上，換個DataFrame處理
    if TX_Init_Restaurant_Menus[i].dtype == 'object': 
        TX_Init_Restaurant_Menus[i] = TX_Init_Restaurant_Menus[i].apply(remove_emoji).str.strip()

TX_Init_Restaurant_Menus = TX_Init_Restaurant_Menus.replace('amp;' , '')                                                    # 刪除贅字 amp;
TX_Init_Restaurant = TX_Init_Restaurant.replace('amp;' , '')

TX_Init_Restaurant_Menus = TX_Init_Restaurant_Menus.replace(', ' , ' , ')                                                   # 將', '改成','
TX_Init_Restaurant = TX_Init_Restaurant.replace(', ' , ' , ')
TX_Init_Restaurant['Restaurant_Category'] = TX_Init_Restaurant['Restaurant_Category'].replace(', ' , ',')                   # 刪除逗號旁邊的空格，方便後續df.explode多值拆開

for i in TX_Init_Restaurant.columns:                                                                                        # 同上，字母轉換成Snake_Cake型式
    if TX_Init_Restaurant[i].dtype == 'object':
        TX_Init_Restaurant[i] = TX_Init_Restaurant[i].str.title()

for i in TX_Init_Restaurant_Menus.columns:                                                                                  # 同上，字母轉換成Snake_Cake型式
    if TX_Init_Restaurant_Menus[i].dtype == 'object':
        TX_Init_Restaurant_Menus[i] = TX_Init_Restaurant_Menus[i].str.title()
        
TX_Init_Restaurant_Menus = TX_Init_Restaurant_Menus.replace("'S" , "'s")                                                    # 同上，後綴詞「's」在上面的 .title 會變成大寫，這邊將其修正回小寫                
TX_Init_Restaurant = TX_Init_Restaurant.replace("'S" , "'s")

##################################################################################################################################################################################################
# 4-1. 提取 餐廳類別 TX_Init_Restaurant_Category 資料表 
    # 因數據呈現方式為一串單詞+逗號，將其拆開，方便在分析時觀察熱門餐廳的類型
##################################################################################################################################################################################################

TX_Init_Restaurant['Restaurant_Category'] = TX_Init_Restaurant['Restaurant_Category'].str.split(',')
TX_Init_Restaurant_Category = TX_Init_Restaurant.explode('Restaurant_Category')                                             # 將DataFrame中某一列的多值拆開，每個值各生成一行，並保持其他數據不變
TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.drop(columns = ['Position','Restaurant_Price_Range',              # 只保留id、name、category，以觀察餐廳類型
                                                                          'Score','Comments','Address',
                                                                          'States_Abbr','Lat','Lng'])

for i in TX_Init_Restaurant_Category:                                                                                       # 刪除TX_Init_Restaurant_Category頭尾空值
    if TX_Init_Restaurant_Category[i].dtype == 'object': 
        TX_Init_Restaurant_Category[i] = TX_Init_Restaurant_Category[i].str.strip()

TX_Init_Restaurant = TX_Init_Restaurant.drop(columns = 'Restaurant_Category')                                               # 移除原資料表的Restaurant_Category欄

################################################################################################################################################################################################## 
# 4-2. 提取 餐廳位置 TX_Init_Restaurant_Location 資料表
##################################################################################################################################################################################################

TX_Init_Restaurant_Location = TX_Init_Restaurant.drop(columns = ['Restaurant_Name', 'Position',                             # 取有關 Location 的數據，刪除不需依傲的欄位
                                                                 'Restaurant_Price_Range','Score','Comments'])

for i in TX_Init_Restaurant_Location:                                                                                       # 取這個 DataFrame 的所有columns
    if TX_Init_Restaurant_Location[i].dtype == 'object':                                                                    # 如果該 columns 型態為文字
        TX_Init_Restaurant_Location[i] = TX_Init_Restaurant_Location[i].str.strip()                                         # 去除前後空值

TX_Init_Restaurant = TX_Init_Restaurant.drop(columns = ['Address','States_Abbr','Lat','Lng',])                              # 移除原資料表的Restaurant_Category欄（不在這次的分析範圍）

##################################################################################################################################################################################################
# 5. 檢查需求欄位數據
##################################################################################################################################################################################################

# Res_Cate_Count = TX_Init_Restaurant_Category['Restaurant_Category'].value_counts()                                        # 檢查各餐廳分類數量

TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.replace('Family Friendly','Family Meals')                         # 將大量出現、名稱相近的分類合併，避免重複歸類，提升分析的一致性、準確性
TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.replace('Group Friendly','Family Meals')
TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.replace('Sandwich','Sandwiches')
TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.replace('Salad','Salads')
TX_Init_Restaurant_Category = TX_Init_Restaurant_Category.replace('Breakfast & Brunch','Breakfast And Brunch')

##################################################################################################################################################################################################
# 6. 匯出
##################################################################################################################################################################################################

TX_Init_Restaurant.to_csv('TX_Restaurant.csv' , index=False)
TX_Init_Restaurant_Menus.to_csv('TX_Restaurant_Menus.csv' , index=False)
TX_Init_Restaurant_Category.to_csv('TX_Restaurant_Category.csv' , index=False)
TX_Init_Restaurant_Location.to_csv('TX_Restaurant_Location.csv' , index=False)