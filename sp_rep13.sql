-- cotizaciones de la web que fueron a inspeccion y emitidas

-- Creado    : 15/02/2012 - Autor: Federico Coronado

drop procedure sp_rep13;

create procedure "informix".sp_rep13()
returning 
char(7),
char(7),
date;
/*char(10),
varchar(5),
varchar(50),   --nombre_agente
varchar(50),   --_nombre_cliente
varchar(50),   --Zona
varchar(50),   --_nombre_tipo
varchar(50),   --_marca
varchar(50),   --_modelo
varchar(20),      --_nuevo
dec(16,2),       --suma_asegurada
date,          --_fecha_cotizacion
varchar(20),
varchar(50),
varchar(50),
smallint,      --_estado_inspeccion
smallint,      --_inspeccion
varchar(50);
*/
define  _no_cotizacion     char(10);
define  _no_documento      varchar(20);
define  _cod_agente        varchar(5);
define  _nombre_agente     varchar(50);
define  _nombre_cliente    varchar(50);
define  _estado_auto       varchar(20);
define _nuevo              integer;
define _nombre_tipo        varchar(50);
define _marca              varchar(50);
define _modelo             varchar(50);
define _fecha_cotizacion   date;
define _estado_inspeccion  smallint;
define _inspeccion         smallint;
define _cnt_insp           smallint;
define _estado_poliza      varchar(50);
define _mando              varchar(50);
define _estado_inspeccion1 varchar(50);
define _zona               varchar(50);
define _suma_asegurada     dec(16,2);
define _periodo            varchar(7);
define _fecha              date;
define _periodo_hoy        varchar(7);

set isolation to dirty read;
--SET DEBUG FILE TO "sp_web11.trc";
--TRACE ON;   

let _fecha = today;

select cob_periodo
  into _periodo
  from deivid:parparam;
  
  --ultimo dia del mes del periodo
  call sp_sis39(_fecha) RETURNING _periodo_hoy;
  
  if _periodo <> _periodo_hoy then
	CALL sp_sis36(_periodo) RETURNING _fecha;
  end if
/*
foreach
	select no_cotizacion, 
	       cod_agente,
		   nombre_agt,
		   nombre_cliente, 
		   nombre_tipo, 
		   marca, 
		   modelo,
		   nuevo_usado,
		   fecha_cotizacion, 
		   estado_inspeccion, 
		   inspeccion,
		   suma_asegurada
      into _no_cotizacion,
	       _cod_agente,
		   _nombre_agente,
		   _nombre_cliente,
		   _nombre_tipo,
		   _marca,
		   _modelo,
		   _nuevo,
		   _fecha_cotizacion,
		   _estado_inspeccion,
		   _inspeccion,
		   _suma_asegurada
      from cot_web
	 where suma_asegurada <> 0
  order by fecha_cotizacion,no_cotizacion ASC
	  
	  select no_documento
	    into _no_documento
	    from emisiones_web
	   where no_cotizacion = _no_cotizacion;
	 
	   let _mando = "";
	 
	   if _no_documento is null or trim(_no_documento) = '' then
			let _estado_poliza = "No Emitida";
	   else
			let _estado_poliza = "Emitida";
	   end if
	   
	   if _nuevo = 0 then
			let _estado_auto = "Auto Usado";
				if _estado_inspeccion = 1 then
					let _mando = "Fue a Inspeccion";
				end if
	   else
			let _estado_auto = "Auto Nuevo";
	   end if
	 
	   select count(*)
		 into _cnt_insp
	     from insp_cot_pend
		where no_cotizacion = _no_cotizacion;
		
		if _cnt_insp > 0 then
			--let _inspeccion = 1;
			let _estado_inspeccion1 = "Se realizo la inspeccion";
		else 
		    --let _inspeccion = 0;
			let _estado_inspeccion1 = "No se realizo la inspeccion";
		end if
		
		select b.nombre
		  into _zona
		  from agtagent a inner join agtvende b on a.cod_vendedor = b.cod_vendedor
         where cod_agente = _cod_agente;
	  
	  return _no_cotizacion,
			 _cod_agente,
			 _nombre_agente,
			 _zona,
	         _nombre_cliente,
	         _nombre_tipo,
	         _marca,
	         _modelo,
	         _estado_auto,
			 _suma_asegurada,
	         _fecha_cotizacion,
			 _no_documento,
			 _mando,
			 _estado_poliza,
	         _estado_inspeccion,
	         _inspeccion,
			 _estado_inspeccion1
	  with resume;

end foreach
*/
return _periodo,
	   _periodo_hoy,
	   _fecha;
end procedure