-- Procedimiento que verifica las promotorias vs los ejecutivos zona 1 y zona 2
-- 
-- Creado :27/06/2025 - Autor: Armando Moreno M.
--
drop procedure sp_sis523;		
create procedure sp_sis523()
returning smallint,varchar(100);
		  	
define _cnt,_cnt_acum			 smallint;
define _no_documento char(20);
define _mensaje      varchar(100);


set isolation to dirty read;

begin 

--Verificador que determina si hay Zonas 2, asignadas a Ramos Generales
 
select count(*)
  into _cnt
  from parpromo par
 inner join prdramo ram on ram.cod_ramo = par.cod_ramo
 inner join agtagent agt on agt.cod_agente = par.cod_agente
 inner join agtvende zon on zon.cod_vendedor = par.cod_vendedor
 where ram.cod_area != 2
   and zon.nombre like '2.%';

let _mensaje = "";
let _cnt_acum = 0;

if _cnt > 0 then
	let _mensaje = "Error,Zona2 a Ramo Gen.";
	let _cnt_acum = 1;
end if

--Verificador que determina si hay Zonas 1 asignadas a Ramos de Personas.
select count(*)
  into _cnt
  from parpromo par
 inner join prdramo ram on ram.cod_ramo = par.cod_ramo
 inner join agtagent agt on agt.cod_agente = par.cod_agente
 inner join agtvende zon on zon.cod_vendedor = par.cod_vendedor
 where ram.cod_area = 2
   and zon.nombre like '1.%';
   
if _cnt > 0 then
	let _mensaje = _mensaje || ";Error,Zona1 a Ramo Persona.";
	let _cnt_acum = _cnt_acum + 1;
end if

--Verifica que la asignación de las Zonas 2 no se haga a Ramos Generales
select count(*)
  into _cnt
  from agtvende zon
 inner join agtagent cor on cor.cod_vendedor = zon.cod_vendedor
   and zon.nombre like '2.%';
   
if _cnt > 0 then
	let _mensaje = _mensaje || ";Asig.Zona2 a Ramo Gen.";
	let _cnt_acum = _cnt_acum + 1;
end if

--Verifica que la asignación de las Zonas 1 no se haga a Ramos  de Personas
select count(*)
  into _cnt
  from agtvende zon
 inner join agtagent cor on cor.cod_vendedor2 = zon.cod_vendedor
   and zon.nombre like '1.%';

if _cnt > 0 then
	let _mensaje = _mensaje || ";Asig.Zona1 a Ramo Persona.";
	let _cnt_acum = _cnt_acum + 1;
end if
end 
if _cnt_acum = 0 then
	return 0, 'Proceso Completado.';
else
	return 1, _mensaje;
end if
end procedure;

--Se debe reversar lo res_notrx