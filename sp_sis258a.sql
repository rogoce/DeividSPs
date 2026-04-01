--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis258() 

drop procedure sp_sis258a;
create procedure sp_sis258a(a_cod_manzana char(15), a_manzana varchar(100), a_cod_categoria char(3), a_latitud dec(10,8), a_longitud dec(10,8), a_uuid varchar(50))
returning	integer			as error_,
			integer			as error_isam,
			varchar(100)	as descripcion;

define _error_desc			varchar(100);    
define _cod_barrio			char(4);           
define _cod_corregimiento	char(2);           
define _cod_provincia			char(2);           
define _cod_distrito			char(2);       
define _cnt_prov				smallint;      
define _cnt_dist				smallint;      
define _cnt_corr				smallint;      
define _cnt_barr				smallint;      
define _cnt_man				smallint;      
define _error					integer;      
define _error_isam			integer;  

let _cod_provincia = a_cod_manzana[1,2];
let _cod_distrito = a_cod_manzana[3,4];
let _cod_corregimiento = a_cod_manzana[5,6];
let _cod_barrio = a_cod_manzana[7,10];

let _cnt_prov = 0;
let _cnt_dist = 0;
let _cnt_corr = 0;
let _cnt_barr = 0;
let _cnt_man = 0;

--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc

	return	_error,
			_error_isam,
			a_cod_manzana;
end exception

let _cod_provincia = a_cod_manzana[1,2];
let _cod_distrito = a_cod_manzana[3,4];
let _cod_corregimiento = a_cod_manzana[5,6];
let _cod_barrio = a_cod_manzana[7,10];

let _cnt_prov = 0;
let _cnt_dist = 0;
let _cnt_corr = 0;
let _cnt_barr = 0;
let _cnt_man = 0;

select count(*)
  into _cnt_prov
  from emiman01
 where cod_provincia = _cod_provincia;

if _cnt_prov is null then
	let _cnt_prov = 0;
end if

if _cnt_prov = 0 then
	insert into emiman01(
			cod_provincia,
			nombre)
	values(_cod_provincia,
			'PENDIENTE');
end if

select count(*)
  into _cnt_dist
  from emiman02
 where cod_provincia = _cod_provincia
   and cod_distrito = _cod_distrito;

if _cnt_dist is null then
	let _cnt_dist = 0;
end if

if _cnt_prov = 0 then
	insert into emiman02(
			cod_provincia,
			cod_distrito,
			nombre)
	values(_cod_provincia,
			_cod_distrito,
			'PENDIENTE');
end if

select count(*)
  into _cnt_corr
  from emiman03
 where cod_provincia = _cod_provincia
   and cod_distrito = _cod_distrito
   and cod_correg = _cod_corregimiento;

if _cnt_corr is null then
	let _cnt_corr = 0;
end if

if _cnt_corr = 0 then
	insert into emiman03(
			cod_provincia,
			cod_distrito,
			cod_correg,
			nombre)
	values(_cod_provincia,
			_cod_distrito,
			_cod_corregimiento,
			'PENDIENTE');
end if

select count(*)
  into _cnt_barr
  from emiman04
 where cod_provincia = _cod_provincia
   and cod_distrito = _cod_distrito
   and cod_correg = _cod_corregimiento
   and cod_barrio = _cod_barrio;

if _cnt_barr is null then
	let _cnt_barr = 0;
end if

if _cnt_barr = 0 then
	insert into emiman04(
			cod_provincia,
			cod_distrito,
			cod_correg,
			cod_barrio,
			nombre)
	values(_cod_provincia,
			_cod_distrito,
			_cod_corregimiento,
			_cod_barrio,
			'PENDIENTE');
end if

select count(*)
  into _cnt_man
  from emiman05
 where cod_manzana = a_cod_manzana;

if _cnt_man is null then
	let _cnt_man = 0;
end if

if _cnt_man = 0 then
	insert into emiman05(
				cod_provincia,
				cod_distrito,
				cod_correg,
				cod_barrio,
				cod_manzana,
				numero,
				referencia,
				cod_categoria,
				latitud,
				longitud,
				uuid)
	values(	_cod_provincia,
				_cod_distrito,
				_cod_corregimiento,
				_cod_barrio,
				a_cod_manzana,
				'000',
				a_manzana,
				a_cod_categoria,
				a_latitud,
				a_longitud,
				a_uuid);
				
	return 0,0,'Actualización Exitosa';
else
	return 1,0,'Manzana ya existe';
end if


end
end procedure;