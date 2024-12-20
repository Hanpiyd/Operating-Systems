/*LAB2 CHALLENGE 1: 2210713*/ 
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <best_fit_pmm.h>
#include <stdio.h>

/* In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
   on receiving a request for memory, scans along the list for the first block that is large enough to
   satisfy the request. If the chosen block is significantly larger than that requested, then it is 
   usually split, and the remainder added to the list as another free block.
   Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
*/

// you should rewrite functions: default_init,default_init_memmap,default_alloc_pages, default_free_pages.
/*
 * Details of FFMA
 * (1) Prepare: In order to implement the First-Fit Mem Alloc (FFMA), we should manage the free mem block use some list.
 *              The struct free_area_t is used for the management of free mem blocks. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list implementation.
 *              You should know howto USE: list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *              Another tricky method is to transform a general list struct to a special struct (such as struct page):
 *              you can find some MACRO: le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.)
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *              This fun is used to init a free block (with parameter: addr_base, page_number).
 *              First you should init each page (in memlayout.h) in this free block, include:
 *                  p->flags should be set bit PG_property (means this page is valid. In pmm_init fun (in pmm.c),
 *                  the bit PG_reserved is setted in p->flags)
 *                  if this page  is free and is not the first page of free block, p->property should be set to 0.
 *                  if this page  is free and is the first page of free block, p->property should be set to total num of block.
 *                  p->ref should be 0, because now p is free and no reference.
 *                  We can use p->page_link to link this page to free_list, (such as: list_add_before(&free_list, &(p->page_link)); )
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * (4) default_alloc_pages: search find a first free block (block size >=n) in free list and reszie the free block, return the addr
 *              of malloced block.
 *              (4.1) So you should search freelist like this:
 *                       list_entry_t le = &free_list;
 *                       while((le=list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) In while loop, get the struct page and check the p->property (record the num of free block) >=n?
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) If we find this p, then it' means we find a free block(block size >=n), and the first n pages can be malloced.
 *                     Some flag bits of this page should be setted: PG_reserved =1, PG_property =0
 *                     unlink the pages from free_list
 *                     (4.1.2.1) If (p->property >n), we should re-caluclate number of the the rest of this free block,
 *                           (such as: le2page(le,page_link))->property = p->property - n;)
 *                 (4.1.3)  re-caluclate nr_free (number of the the rest of all free block)
 *                 (4.1.4)  return p
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * (5) default_free_pages: relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

//extra function
size_t
get_num(size_t n){
    size_t count = 1;
    while(count < n){
        count <<= 1;
    }
    return count;
}

//finished
static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

//finished
static void
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    nr_free += n;
    size_t block_size = 1;
    while(n > 0){
        size_t temp = n & 1;
        n >>= 1;
        if(temp != 0){
            base->property = block_size;
            SetPageProperty(base);
            list_entry_t *le = &free_list;
            while((le = list_next(le)) != &free_list){
                struct Page *p = le2page(le, page_link);
                if(p->property > base->property ||( p->property == base->property && base < p)){
                    break;
                }
            }
            list_add_before(le, &(base->page_link));
            base += block_size;
        }
        block_size <<= 1;
    }
}

//finished
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    size_t size = get_num(n);
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while((le = list_next(le)) != &free_list){
        struct Page *p = le2page(le, page_link);
        if(p->property >= size){
            page = p;
            break;
        }
    }
    if(page != NULL){
        while(page->property > size){
            page->property >>= 1;
            struct Page *child = page + page->property;
            child->property = page->property;
            SetPageProperty(child);
            list_entry_t *temp_addr = &free_list;
            while((temp_addr = list_next(temp_addr)) != &free_list){
                struct Page *p = le2page(temp_addr, page_link);
                if(p->property > child->property ||( p->property == child->property && p > child)){
                    break;
                }
            }
            list_add_before(temp_addr, &(child->page_link));
        }
        nr_free -= size;
        ClearPageProperty(page);
        assert(page->property == size);
        list_del(&(page->page_link));
    }
    return page;
}

//finished
static void
best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    n = get_num(n);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_entry_t *le = &free_list;
    while((le = list_next(le)) != &free_list){
        p = le2page(le, page_link); 
        if(p->property > base->property ||( p->property == base->property && p > base)){
            break;
        }
    }
    list_add_before(le, &(base->page_link));
    if ((p->property == base->property) && (p + p->property == base))
    {
        p->property += base->property;
        ClearPageProperty(base);
        list_del(&(base->page_link));
        base = p;
    }
    le = &(base->page_link);
    while ((le = list_next(le)) != &free_list)
    {
        p = le2page(le, page_link);
        if ((p->property == base->property) && (base + base->property == p))
        {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            le = &(base->page_link);
        }
        else if((p->property == base->property) && (p + p->property == base)){
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
            le = &(base->page_link);
        }
        else if (base->property < p->property || (base->property == p->property && base + base->property < p))
        {
            list_entry_t *targetLe = le;
            if (targetLe != list_next(&base->page_link))
            {
                list_del(&(base->page_link));
                list_add_before(targetLe, &(base->page_link));
            }
            break;
        }
        else if(list_next(le) == &free_list){
            list_del(&(base->page_link));
            list_add(le, &(base->page_link));
            break;
        }
    }
} 

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void)
{
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count++, total += p->property;
    }
    assert(total == nr_free_pages());
    basic_check();
    struct Page *p0 = alloc_pages(26), *p1;
    assert(p0 != NULL);
    assert(!PageProperty(p0));
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
    unsigned int nr_free_store = nr_free;
    nr_free = 0;
    free_pages(p0, 26);
    p0 = alloc_pages(6);
    p1 = alloc_pages(10);
    assert((p0 + 8)->property == 8);
    free_pages(p1, 10); 
    assert((p0 + 8)->property == 8);
    assert(p1->property == 16);
    p1 = alloc_pages(16); 
    free_pages(p0, 6); 
    assert(p0->property == 16);
    free_pages(p1, 16); 
    assert(p0->property == 32);
    p0 = alloc_pages(8); 
    p1 = alloc_pages(9); 
    free_pages(p1, 9);   
    assert(p1->property == 16);
    assert((p0 + 8)->property == 8);
    free_pages(p0, 8); 
    assert(p0->property == 32);
    p0 = alloc_pages(5);
    p1 = alloc_pages(16);
    free_pages(p1, 16);
    assert(list_next(&(free_list)) == &((p1 - 8)->page_link));
    free_pages(p0, 5);
    assert(list_next(&(free_list)) == &(p0->page_link));
    p0 = alloc_pages(5);
    p1 = alloc_pages(16);
    free_pages(p0, 5);
    assert(list_next(&(free_list)) == &(p0->page_link));
    free_pages(p1, 16);
    assert(list_next(&(free_list)) == &(p0->page_link));
    p0 = alloc_pages(26);
    assert(nr_free == 0);
    nr_free = nr_free_store;
    free_list = free_list_store;
    free_pages(p0, 26);
    le = &free_list;
    while ((le = list_next(le)) != &free_list)
    {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}
//这个结构体在
const struct pmm_manager best_fit_pmm_manager = {
    .name = "best_fit_pmm_manager",
    .init = best_fit_init,
    .init_memmap = best_fit_init_memmap,
    .alloc_pages = best_fit_alloc_pages,
    .free_pages = best_fit_free_pages,
    .nr_free_pages = best_fit_nr_free_pages,
    .check = best_fit_check,
};

