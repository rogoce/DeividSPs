create procedure "informix".pd_emihcmm(old_no_poliza char(10),
                            old_no_cambio char(3))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

 
    --  Delete all children in "emihcmdd
    delete from emihcmd
    where  no_poliza = old_no_poliza
     and   no_cambio = old_no_cambio;

end procedure                                                                                              