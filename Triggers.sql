create trigger "informix".td_emipomae delete on "informix".emipomae 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emipomae(old_del.no_poliza 
    ));

create trigger "informix".td_emidepen delete on "informix".emidepen 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emidepen(old_del.no_poliza 
    ,old_del.no_unidad ,old_del.cod_cliente ));

create trigger "informix".td_emipouni delete on "informix".emipouni 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emipouni(old_del.no_poliza 
    ,old_del.no_unidad ));

create trigger "informix".td_emihcmm delete on "informix".emihcmm 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emihcmm(old_del.no_poliza 
    ,old_del.no_cambio ));

create trigger "informix".td_emigloco delete on "informix".emigloco 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emigloco(old_del.no_poliza 
    ,old_del.no_endoso ,old_del.orden ));

create trigger "informix".td_emireagm delete on "informix".emireagm 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emireagm(old_del.no_poliza 
    ,old_del.no_cambio ));

create trigger "informix".td_emifacon delete on "informix".emifacon 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emifacon(old_del.no_poliza 
    ,old_del.no_endoso ,old_del.no_unidad ,old_del.cod_cober_reas ,old_del.orden 
    ));

create trigger "informix".td_emipocob delete on "informix".emipocob 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emipocob(old_del.no_poliza 
    ,old_del.no_unidad ,old_del.cod_cobertura ));

create trigger "informix".td_emifian delete on "informix".emifian1 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emifian(old_del.no_poliza 
    ,old_del.no_unidad ));

create trigger "informix".td_emifigar delete on "informix".emifigar 
    referencing old as old_del
    for each row
        (
        execute procedure "informix".pd_emifigar(old_del.no_poliza 
    ,old_del.no_unidad ,old_del.cod_tipogar ));



 

