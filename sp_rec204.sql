-- Procedimiento que Retorna la Prioridad en la que se debe pagar la asignacion

-- Creado:	24/05/2013

-- SIS v.2.0 - sp_cob29 -- DEIVID, S.A.

drop procedure sp_rec204;

create procedure sp_rec204(a_cod_asignacion	char(10))
returning smallint;

define _prioridad_caso	smallint;
define _prioridad_final	smallint;

define _no_documento		char(20);
define _no_poliza			char(20);
define _cod_asegurado		char(10);
define _cod_reclamante		char(10);
define _cod_agente			char(10);
define _agente_agrupado		char(10);
define _cod_tipopago        char(3);

set isolation to dirty read;

let _prioridad_final = 0;

select no_documento,
       cod_asegurado,
	   cod_reclamante,
	   cod_tipopago
  into _no_documento,
       _cod_asegurado,
	   _cod_reclamante,
	   _cod_tipopago
  from atcdocde
 where cod_asignacion = a_cod_asignacion;

 let _no_poliza = sp_sis21(_no_documento);
 
-- Polizas

select prioridad
  into _prioridad_caso
  from recpripag
 where tipo_caso  = 1 
   and valor_caso = _no_documento;

if _prioridad_caso is null then
	let _prioridad_caso = 0;
end if

if _prioridad_caso > _prioridad_final then
	let _prioridad_final = _prioridad_caso;
end if
 
-- Asegurado

select prioridad
  into _prioridad_caso
  from recpripag
 where tipo_caso  = 2 
   and valor_caso = _cod_asegurado;

if _prioridad_caso is null then
	let _prioridad_caso = 0;
end if

if _prioridad_caso > _prioridad_final then
	let _prioridad_final = _prioridad_caso;
end if

-- Reclamante

select prioridad
  into _prioridad_caso
  from recpripag
 where tipo_caso  = 3 
   and valor_caso = _cod_reclamante;

if _prioridad_caso is null then
	let _prioridad_caso = 0;
end if

if _prioridad_caso > _prioridad_final then
	let _prioridad_final = _prioridad_caso;
end if

-- Corredor

foreach
 select cod_agente
   into _cod_agente
   from emipoagt
  where no_poliza = _no_poliza
  
  select agente_agrupado
    into _agente_agrupado
	from agtagent
   where cod_agente = _cod_agente;
   
	let _cod_agente = _agente_agrupado;
	
	select prioridad
	  into _prioridad_caso
	  from recpripag
	 where tipo_caso  = 4 
	   and valor_caso = _cod_agente;

	if _prioridad_caso is null then
		let _prioridad_caso = 0;
	end if

	if _prioridad_caso > _prioridad_final then
		let _prioridad_final = _prioridad_caso;
	end if

end foreach

if _cod_tipopago = '003' then	--Pago a Asegurado
else
	let _prioridad_final = 0;
end if

return _prioridad_final;

end procedure
