create procedure "informix".pd_emigloco(old_no_poliza char(10),
                             old_no_endoso char(5),
                             old_orden smallint)
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emiglofa"
    delete from emiglofa
    where  no_poliza = old_no_poliza
     and   no_endoso = old_no_endoso
     and   orden = old_orden;

end procedure                                                                     
