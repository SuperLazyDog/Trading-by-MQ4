//
//  SampleDataStruct.h
//  Basic Review
//
//  Created by 徐伟达 on 2017/6/19.
//  Copyright © 2017年 徐伟达. All rights reserved.
//

#ifndef SampleDataStruct_h
#define SampleDataStruct_h

#include <stdio.h>
#include "Bool.h"
#include "MemorySet.h"
#include "String.h"

//---------------------------------------------------------------------------
//                            测试用自定义数据结构
//---------------------------------------------------------------------------
/*-------------------------------------------------------
                         笔记
  -------------------------------------------------------
                     2017/06/19
 目的: 自定义一个相对复杂的数据类型, 用在学习算法过程中
 数据结构：人 = 精神（spirit) + 肉体(flesh)
              精神: 性格(列举型)
              肉体: 身体情况(列举型)
 意义: 作为以后开发的模板
 
 -------------------------------------------------------*/

//-------------------------------------------------------
//                       数据结构
//-------------------------------------------------------
typedef int Type;
typedef char * Name;
typedef enum {//性格列举
    char_open,
    char_shy
} CharacterEnum;
typedef Type Character;
typedef struct {//精神
    Character charactristic;
} Spirit;
typedef Spirit * SPIRITLP;

typedef enum {//身体列举
    body_power,
    body_week
} PhsicsEnum;
typedef Type BodyType;
typedef struct { //身体
    BodyType body;
} Flesh;
typedef Flesh * FLESHLP;

//人的定义
typedef struct {
    Name name;
    Flesh body;
    Spirit mental;
} Human;
typedef Human * HUMANLP;

//-------------------------------------------------------
//                        初始化
//-------------------------------------------------------
//---------------------------------------------------------------------------
//                              操作函数
//---------------------------------------------------------------------------
//-------------------------------------------------------
//                     管理测试的函数
//-------------------------------------------------------
void dataStructTest();
//-------------------------------------------------------
//                       字符输出
//-------------------------------------------------------
String spirit_tos(SPIRITLP p_spirit);
String flesh_tos(FLESHLP p_flesh);
//-------------------------------------------------------
//                        创建
//-------------------------------------------------------
SPIRITLP createSpirit(Character character);
FLESHLP createFlesh(BodyType bodyType);
HUMANLP creatOneHuman(HUMANLP human, Name name, FLESHLP p_body, SPIRITLP p_spirit);
//-------------------------------------------------------
//                        展示
//-------------------------------------------------------
void showHuman(HUMANLP human, bool isBrief);

#endif /* SampleDataStruct_h */
