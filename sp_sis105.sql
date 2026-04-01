drop procedure sp_sis105;

create procedure sp_sis105()
returning integer,
          char(50);

define _cod_grupo	char(10);
define _cod_cliente	char(10);
define _nombre		char(100);

delete from clideagr;
delete from clidedup;

foreach
 select grupon
   into _cod_grupo
   from deivid_tmp:clidup
  group by grupon

	foreach
	 select nombre
	   into _nombre
	   from deivid_tmp:clidup
	  where grupon = _cod_grupo
		exit foreach;
	end foreach

	if _nombre is null then
		let _nombre = "SIN NOMBRE";
	end if

	insert into clideagr
	values (_nombre, _cod_grupo, 0);

	foreach
	 select codigo_cliente,
	        nombre
	   into _cod_cliente,
	        _nombre
	   from deivid_tmp:clidup
	  where grupon = _cod_grupo
		
		if _cod_cliente[1,1] = "0" then
			let _cod_cliente = _cod_cliente[2,10];
		end if

		insert into clidedup (cod_clt, nombre, ced, dir, tel, nac, cod_gpo, por, seleccion, declinados)
		values (_cod_cliente, _nombre, "", "", "", "", _cod_grupo, "", 0, 0);		

	end foreach

end foreach

return 0, "Actualizacion Exitosa";

end procedure
