//
//  SampleDataStruct.c
//  Basic Review
//
//  Created by 徐伟达 on 2017/6/19.
//  Copyright © 2017年 徐伟达. All rights reserved.
//

#include "SampleDataStruct.h"


//---------------------------------------------------------------------------
//                               本地函数声明
//---------------------------------------------------------------------------
static HUMANLP createOne() {
    HUMANLP temp = NULL;
    if((temp = (HUMANLP)mallocPro(temp, sizeof(Human), GETSTR_MEMSET))) {
        return temp;
    }
    return NULL;
}

static bool setOne(HUMANLP human, Name name, FLESHLP p_body, SPIRITLP p_spirit) {
    human->name = name;
    human->body = *p_body;
    human->mental = *p_spirit;
    
    return true;
}
//-------------------------------------------------------
//                      共有变量
//-------------------------------------------------------


//---------------------------------------------------------------------------
//                              操作函数
//---------------------------------------------------------------------------
//-------------------------------------------------------
//                     管理测试的函数
//-------------------------------------------------------
void dataStructTest() {
    HUMANLP temp = NULL;
    FLESHLP flesh = createFlesh(body_power);
    SPIRITLP spirit = createSpirit(char_open);
    temp = creatOneHuman(temp, "Xu Weida", flesh, spirit);
    /*FLESHLP body = (FLESHLP)malloc(sizeof(Flesh));
    SPIRITLP spirit = (SPIRITLP)malloc(sizeof(spirit));
    if(!body || !spirit) {
        puts("wrong");
        return;
    }
    body->body = body_power;
    spirit->charactristic = char_open;
    temp = creatOneHuman(temp, "Xu Weida", body, spirit);
    showHuman(temp, true);*/
    showHuman(temp, false);
}
//-------------------------------------------------------
//                       字符输出
//-------------------------------------------------------
String spirit_tos(SPIRITLP p_spirit) {
    switch (p_spirit->charactristic) {
        case char_open:
            return "OPEN";
            break;
        case char_shy:
            return "SHY";
            break;
        default:
            return "nil";
            break;
    }
}
String flesh_tos(FLESHLP p_flesh) {
    switch (p_flesh->body) {
        case body_power:
            return "POWER";
            break;
        case body_week:
            return "WEEK";
            break;
        default:
            return "nil";
            break;
    }
}
//-------------------------------------------------------
//                        创建
//-------------------------------------------------------
SPIRITLP createSpirit(Character character) { //构造精神面
    SPIRITLP temp = NULL;
    if((temp = (SPIRITLP)mallocPro(temp, sizeof(Spirit), GETSTR_MEMSET))) {
        temp->charactristic = character;
        return temp;
    }
    return NULL;
}

FLESHLP createFlesh(BodyType bodyType) { //构造身体面
    FLESHLP temp = NULL;
    if((temp = (FLESHLP)mallocPro(temp, sizeof(Flesh), GETSTR_MEMSET))) {
        temp->body = bodyType;
        return temp;
    }
    return NULL;
}

HUMANLP creatOneHuman(HUMANLP human, Name name, FLESHLP p_body, SPIRITLP p_spirit) {
    human = createOne();
    if(human) {
        setOne(human, name, p_body, p_spirit);
        return human;
    }
    return NULL;
}
//-------------------------------------------------------
//                        展示
//-------------------------------------------------------
void showHuman(HUMANLP human, bool isBrief) {
    switch (isBrief) {
        case false:
            puts("------------------------------------");
            printf("name: %s\n\n", human->name);
            puts(  "flesh: ");
            printf("        phisics: %s\n", flesh_tos(&human->body));puts("");
            puts(  "spirit: ");
            printf("        character: %s\n", spirit_tos(&human->mental));
            puts("------------------------------------");
            break;
        case true:
            printf("name: %s\n\n", human->name);
            printf("phisics: %s\n", flesh_tos(&human->body));puts("");
            printf("character: %s\n", spirit_tos(&human->mental));
            puts("------------------------------------");
            break;
            break;
        default:
            break;
    }
}
