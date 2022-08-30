/*========================================================================
1. Hozzom lÇtre generikus Set (halmaz) oszt†lyt.
Az oszt†ly egy megval¢sit†sa csak annyi mem¢ri†t foglalhat le, amennyi
feltÇtlenÅl szÅksÇges. Az elemsz†m nem ismert elìre Çs dinamikusan v†ltoz¢.

Az ÇrvÇnyes mñveletek:
1. Elem hozz†vÇtetele a halmazhoz: 	halmaz = elem + halmaz;
2. KÇt halmaz egyesitÇse:               halmaz1 = halmaz2 + halmaz3
3. Egy elem rÇsze-e a halmaznak?:       (elem <= halmaz)
4. Egy halmaz rÇsze-e egy m†siknak?:    (halmaz <= halmaz)

20 PONT =================================================================*/

// NULL POINTER ASSIGNMENT HIBA !!!

#include <stddef.h>
#include <iostream.h>

template <class T>
struct SetMember
{
	SetMember<T> * Next;
	T Item;
};

template <class T>
class Set
{
	SetMember<T> * Head;

    public:
	Set() { Head = NULL; };
	void AddItem(T NewItem);
	void AddSet(Set<T> NewSet);
	int ItemOf(T TestItem);
	int PartOf(Set<T> TestSet);
	void Print();
	~Set();
};

template <class T> void Set<T>::AddItem(T NewItem)
{
    SetMember<T> * p;
    if (!ItemOf(NewItem)) {
	p = new SetMember<T>;
	p->Item = NewItem;
	p->Next = Head;
	Head = p;
    };
};

template <class T> void Set<T>::AddSet(Set<T> NewSet)
{
    SetMember<T> * p;
    p = NewSet.Head;
    while (p != NULL) {
	AddItem(p->Item);
	p = p->Next;
    };
};

template <class T> int Set<T>::ItemOf(T TestItem)
{
    SetMember<T> * p;
    int Found = 0;
    p = Head;
    while ((p != NULL) && !Found) {
	Found = (p->Item == TestItem);
	p = p->Next;
    };
    return Found;
};

template <class T> int Set<T>::PartOf(Set<T> TestSet)
{
    SetMember<T> * p;
    int Found = 1;
    p = TestSet.Head;
    while ((p != NULL) && Found) {
	Found = ItemOf(p->Item);
	p = p->Next;
    };
    return Found;
};

template <class T> void Set<T>::Print()
{
    SetMember<T> * p;
    p = Head;
    while (p != NULL) {
	cout << p->Item << ',';
	p = p->Next;
    };
    cout << '\n';
};

template <class T> Set<T>::~Set()
{
    SetMember<T> * p;
    while (Head != NULL) {
	p = Head->Next;
	delete(Head);
	Head = p;
    };
};

int main()
{
    Set<int> A;
    A.AddItem(1);
    A.AddItem(3);
    A.Print();
    A.AddItem(6);
    A.AddItem(3);
    A.Print();
    cout << A.ItemOf(4) << " " << A.ItemOf(3) << '\n';
    Set<int> B;
    B.AddItem(3);
    B.AddItem(6);
    cout << A.PartOf(B) << '\n';
    B.AddItem(7);
    A.AddSet(B);
    A.Print();
    return 0;
};
