#include "Hash_OpenAdressing.h"

//---------------------------------------------------------------------------------------------------------
//                                   开放寻址哈希表(open adressing hash)
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------
//                               本地函数声明
//---------------------------------------------------------------------------


//-------------------------------------------------------
//                      共有变量
//-------------------------------------------------------



//---------------------------------------------------------------------------
//                           测试专用--自定义函数的实现
//---------------------------------------------------------------------------
//---------------------------------------------
//                获取哈希值的函数
//---------------------------------------------
OpenAdressingHash_Key getHashKey_OpenAdressingHash(const OpenAdressingHash_Data *data, SIZE size) {
	return *data % size;
}

//---------------------------------------------
//                再次哈希值的函数
//---------------------------------------------
OpenAdressingHash_Key getReHashKey_OpenAdressingHash(const OpenAdressingHash_Key key, SIZE size) {
	return ((*data) + 1) % 13;
}
//---------------------------------------------
//                  数据对比函数
//---------------------------------------------
bool compareData_OpenAdressingHash(const OpenAdressingHash_Data *ldata, const OpenAdressingHash_Data *rdata) {
	return *ldata == *rdata;
}
//---------------------------------------------
//                  输出格式
//---------------------------------------------
bool showBucket_OpenAdressingHash(OpenAdressingHash_Data *data) {
	printf("%d ", *data);
	return false;
}

//-------------------------------------------------------
//---------------------------------------------
//                获取哈希值的函数
//---------------------------------------------
/*ChainHash_Key getHashKey(const ChainHash_Data *data, int size) {
    //return strlen(data->name) % size;
    if (!strcmp(data->name, "")) {
        return 0;
    }else {
        return data->name[0] % size;
    }
}
//---------------------------------------------
//                  对比函数
//---------------------------------------------
bool compareData_ChainHash(const ChainHash_Data *ldata, const ChainHash_Data *rdata) {
    if(strcmp(ldata->name, rdata->name) == 0) {
        return true;
    }else {
        return false;
    }
}
//---------------------------------------------
//                  输出格式
//---------------------------------------------
bool showNode(ChainHash_Data *data) {
    printf("%s", data->name);
    //printf("OK");
    return true;
}*/
//---------------------------------------------------------------------------
//                               本地函数声明
//---------------------------------------------------------------------------
//---------------------------------------------
//                  设置节点
//---------------------------------------------
static bool setNode_OpenAdressingHash(OpenAdressingHash_Bucket *bucket, const OpenAdressingHash_Data *data, Status_OpenAdressingHash status) {
    bucket->data = data;
	bucket->status = status;
    return true;
}


//---------------------------------------------------------------------------
//                                共有变量
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//                                API函数
//---------------------------------------------------------------------------
//# TODO: 返回结果不用bool，改用enum
//# TODO: 改用函数指针
//# TODO: terminate要清楚哈希表管理器指向的内存  ChainHash
//-------------------------------------------------------
//                     管理测试的函数
//-------------------------------------------------------
void OpenAdressingHashTest() {

}

//-------------------------------------------------------
//                       初始化
//-------------------------------------------------------
bool initialize_OpenAdressingHash(OpenAdressingHash *hashTable, SIZE size) {// 初始化开放寻址哈希表
	int i;
	if (hashTable == NULL) { //一开始为空指针
		hashTable = mallocPro(hashTable, sizeof(hashTable), GETSTR_MEMSET);
		if (hashTable == NULL) {
			return false;
		}
	}
	if ((hashTable->table = callocPro(hashTable->Table, size, sizeof(OpenAdressingHash_Bucket), GETSTR_MEMSET)) == NULL) { //　哈希表的内存初始化失败
		hashTable->size = 0;
		return false;
	}

	hashTable->size = size;
	for (i = 0;i < hashTable->size ; i++) {
		h->table[i]->status = empty;
	}
	return true;
}
//-------------------------------------------------------
//                        检索
//-------------------------------------------------------
//ChainHash_Node *search(const ChainHash *hashTable, const Data *data);
OpenAdressingHash_Bucket *search_OpenAdressingHash(const OpenAdressingHash *hashTable, const OpenAdressingHash_Data *data) {
	int i;
	OpenAdressingHash_Key key = getHashKey(data, hashTable->size);
	OpenAdressingHash_Bucket　*bucket = &hashTable->table[key];

	for (i = 0;((i < hashTable->size) && (bucket->status != empty)) ; i++) {
		if((bucket->status == occupied) && (compareData_OpenAdressingHash(data, &bucket->data)) == true) {
			return bucket;
		}
		key = getReHashKey_OpenAdressingHash(key , hashTable->size);
		bucket = &hashTable->table[key];
	}
	return NULL;
}

//-------------------------------------------------------
//                        追加
//-------------------------------------------------------
bool Insert_Data_OpenAdressingHash(OpenAdressingHash *hashTable, const OpenAdressingHash_Data *data) {
	int i;
	OpenAdressingHash_Key key = getHashKey_OpenAdressingHash(data, hashTable->size);
	OpenAdressingHash_Bucket *bucket = hashTable->table[key];

	if(search_OpenAdressingHash(hashTable, data) != NULL) {
		return false;//　要插入的数据已存在
		//# TODO: 不用这个是否会更快
	}

	for (i = 0; i < hashTable->size; i++) {
		if ((bucket->status == empty) || (p->status == deleted)) {
			setNode_OpenAdressingHash(bucket, data, occupied);
			return true;
		}
		key = getReHashKey_OpenAdressingHash(key, hashTable->size);
		bucket = &hashTable->table[key];
	}

	return false;//哈希表已满
}

//-------------------------------------------------------
//                        删除
//-------------------------------------------------------
bool delete_Data_OpenAdressingHash(OpenAdressingHash *hashTable, const OpenAdressingHash_Data *data) {
	//int i;
	//OpenAdressingHash_key key = getHashKey_OpenAdressingHash(data, hashTable->size);
	OpenAdressingHash_Bucket *bucket = search_OpenAdressingHash(hashTable, data);

	if (bucket == NULL) {
		return false;//要删除的数据不存在
	}
	bucket->status = deleted;
	return true;
}

//-------------------------------------------------------
//                        Dump
//-------------------------------------------------------
void dump_OpenAdressingHash(const OpenAdressingHash *hashTable,
		bool showBucket_OpenAdressingHash(OpenAdressingHash_Data *data)) {
	int i;
	for (i = 0; i < hashTable->size; i++) {
		printf("%d: ", i);
		switch (hashTable->table[i].status) {
			case occupied:
				showBucket_OpenAdressingHash(&(hashTable->table[key].data));//展示数据
				puts("");
				break;
			case empty:
				puts("--空--");
				break;
			case deleted:
				puts("--已删除--");
				break;
		}
	}
	
}

//-------------------------------------------------------
//                       全部删除
//-------------------------------------------------------
void clear_OpenAdressingHash(OpenAdressingHash *hashTable) {
	int i;
	for (i = 0; i < hashTable->size; i++) {
		h->table[i].status = empty;
	}
}

//-------------------------------------------------------
//                      收尾（全删除）
//-------------------------------------------------------
void terminate_OpenAdressingHash(OpenAdressingHash *hashTable) {
	clear_OpenAdressingHash(hashTable);
	free(hashTable->table);
	h->size = 0;
}