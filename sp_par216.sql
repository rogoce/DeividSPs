drop procedure sp_par216;

create procedure sp_par216(a_periodo smallint)
returning integer,
          char(50);

define _cod_ramo			char(3);
define _porc_gasto_admin	dec(16,2);
define _porc_gasto_adquis	dec(16,2);
define _porc_xls			dec(16,2);


foreach
 select cod_ramo,			
		porc_gasto_admin,	
		porc_gasto_adquis,
		porc_xls			
   into _cod_ramo,			
		_porc_gasto_admin,	
		_porc_gasto_adquis,
		_porc_xls
   from parporga
  where periodo = 2004
  

	insert into parporga
	values (_cod_ramo, a_periodo, _porc_gasto_admin, _porc_gasto_adquis, _porc_xls);

end foreach 					

return 0, "Actualizacion Exitosa";

end procedure