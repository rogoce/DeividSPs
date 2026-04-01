   --Info. solocitada por Zuleyka de pólizas con % de comisión, que tienen corredor diercto oficina.
   --Informacion de Corredores
   --  Armando Moreno M. 07/06/2021   
   DROP procedure sp_directos;
   CREATE procedure sp_directos()
   RETURNING char(20), char(10), char(5),char(50),decimal(16,2);

	define _n_agente	    varchar(50);
	define _no_poliza       char(10);
	define _cod_agente      char(5);
	define _tipo_agente     char(1);
	define _no_documento    char(20);
	define v_filtros        varchar(255);
	define _porc_comis      dec(16,2);
	define _valor 			smallint;
	
SET ISOLATION TO DIRTY READ;

let _porc_comis = 0.00;
call sp_pro03('001','001',today,'*') returning v_filtros;

foreach
	select no_poliza,
	       cod_agente,
		   no_documento
	  into _no_poliza,
		   _cod_agente,
		   _no_documento
	  from temp_perfil
	 where seleccionado = 1
	 
	select tipo_agente,nombre
	  into _tipo_agente,_n_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
    let _porc_comis = 0;
	
    if _tipo_agente = 'O' then
		select sum(porc_comis_agt)
		  into _porc_comis
		  from emipoagt
		 where no_poliza = _no_poliza;

		if _porc_comis > 0 then
			return _no_documento,_no_poliza,_cod_agente,_n_agente,_porc_comis with resume;
		else
			continue foreach;
		end if
	else
		continue foreach;
	end if

end foreach	
drop table temp_perfil;
END PROCEDURE;