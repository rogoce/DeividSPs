create procedure "informix".pd_emidepen(old_no_poliza char(10),
                             old_no_unidad char(5),
                             old_cod_cliente char(10))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

    --  Delete all children in "emiprede"
    delete from emiprede
    where  no_poliza = old_no_poliza
     and   no_unidad = old_no_unidad
     and   cod_cliente = old_cod_cliente;

end procedure                                                   
