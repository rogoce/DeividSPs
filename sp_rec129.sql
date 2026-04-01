-- Procedure que Determina si es Necesario el Cierre de Reclamos

-- Creado:	03/10/2006	Autor: Demetrio Hurtado Almanza

drop procedure sp_rec129;

create procedure sp_rec129()
returning integer,
          char(7);

define _periodo1		char(7);
define _periodo2		char(7);			
define _valor_parametro	integer;
define _fecha_actual   	date;

define _ano_ant			smallint;
define _periodo_ant		char(7);			


--SET DEBUG FILE TO "sp_rec129.trc"; 
--TRACE ON;

-- Determina el Periodo Cerrado

select rec_periodo
  into _periodo1
  from parparam
 where cod_compania = "001";

-- Determina el Periodo Actual

select valor_parametro
  into _valor_parametro
  from inspaag
 where codigo_compania  = "001"
   and aplicacion       = "REC"
   and inspaag.version  = "02"
   and codigo_parametro = "fecha_recl_default";

If _valor_parametro = 1 Then      -- Fecha proveniente del servidor

	let _fecha_actual = CURRENT;
	let _fecha_actual = _fecha_actual + 1 units day; --> este proceso corre a las 10 pm por eso le sumo un dia para cuando
	                                                 --> sea el ultimo dia del mes haga el cierre -- Amado 2/10/2013
Else							  

	select valor_parametro
	  into _fecha_actual
	  from inspaag
	 where codigo_compania  = "001"
	   and aplicacion       = "REC"
	   and inspaag.version  = "02"
	   and codigo_parametro = "fecha_recl_valor";

End If

let _periodo2 = sp_sis39(_fecha_actual);

if _periodo2 > _periodo1 then

	let _ano_ant     = _periodo1[1,4];
	let _ano_ant     = _ano_ant - 1;
	let _periodo_ant = _ano_ant || _periodo1[5,7];	
		
	update parparam
	   set rec_periodo     = _periodo2,
	       rec_ano_ant     = _periodo_ant,
		   rec_periodo_ant = _periodo1
	 where cod_compania    = "001";

	return 1, _periodo1;

else

	return 0, _periodo1;

end if

end procedure