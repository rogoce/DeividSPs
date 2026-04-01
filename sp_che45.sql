-- Actualizar los registros de chqcomis que estan incorrectos

-- Creado    : 08/04/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che45;

CREATE PROCEDURE "informix".sp_che45(
a_cod_agente	char(5),
a_no_requis		char(10)
) returning integer,
            char(50);

define _fecha_desde	date;
define _fecha_hasta	date;

select min(fecha_desde)
  into _fecha_desde
  from agtsalhi
 where cod_agente = a_cod_agente;

if _fecha_desde is null then
	return 1, "No Hay Fecha Minima de Historia";
end if

let _fecha_hasta = "28/02/2006";

CALL sp_che02(
"001", 
"001",
_fecha_desde,
_fecha_hasta
);

insert into chqcomis(
	cod_agente,
	no_poliza,
	no_recibo,
	fecha,
	monto,
	prima,
	porc_partic,
	porc_comis,
	comision, 
	nombre,
	no_documento,
	monto_vida,
	monto_danos,
	monto_fianza,
	no_licencia,
	seleccionado,
	fecha_desde,
	fecha_hasta,
	fecha_genera,
	no_requis
	)
	select 
	cod_agente,	  
	no_poliza,	  
	no_recibo,	  
	fecha,		  
	monto,         
	prima,         
	porc_partic,	  
	porc_comis,	  
	comision,	  
	nombre,		  
	no_documento,  
	monto_vida,    
	monto_danos,   
	monto_fianza,  
	no_licencia,   
    1,
	_fecha_desde,
	_fecha_hasta,
	today,
	a_no_requis
	from tmp_agente
	where cod_agente = a_cod_agente;
      
return 0, "Actualizacion Exitosa";

end procedure
