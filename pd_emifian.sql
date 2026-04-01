DROP PROCEDURE pd_emifian;
create procedure "informix".pd_emifian(old_no_poliza char(10),
                            old_no_unidad char(5))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emifigar"
    delete from emifigar
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

    --  Delete all children in "emiavan"
    delete from emiavan
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad;

end procedure                                                                                                                                                     
