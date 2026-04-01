-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 06/12/2022 - Autor: Amado Perez  

drop procedure sp_rwf179;

create procedure sp_rwf179(a_no_poliza char(10), a_cod_cobertura char(5)) 
returning char(1) as cod_cober_reas;

define _cod_ramo        char(3);
define _cod_cober_reas	char(3);
define _casco           smallint;
define _resp            smallint;
define _soda            smallint;

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _casco = 0;
let _resp = 0;

select cod_ramo
  into _cod_ramo
  from emipomae 
 where no_poliza = trim(a_no_poliza);

select cod_cober_reas
  into _cod_cober_reas
  from prdcober
 where cod_ramo = _cod_ramo
   and cod_cobertura = trim(a_cod_cobertura);
   
select count(*)
  into _casco
  from reacobre
 where cod_cober_reas = _cod_cober_reas
   and upper(nombre) like '%CASCO%'; 

select count(*)
  into _resp
  from reacobre
 where cod_cober_reas = _cod_cober_reas
   and upper(nombre) like '%RESP%'; 
   
select count(*)
  into _soda
  from reacobre
 where cod_cober_reas = _cod_cober_reas
   and upper(nombre) like '%SODA%'; 
   
   
if _casco is null then
	let _casco = 0;
end if	

if _resp is null then
	let _resp = 0;
end if	

if _soda is null then
	let _soda = 0;
end if	

if _casco > 0 then
	return 'C';
end if	

if _resp > 0 then
	return 'R';
end if	

if _soda > 0 then
	return 'R';
end if	

if _casco = 0 and _resp = 0 and _soda = 0 then
	return '';
end if	

end procedure