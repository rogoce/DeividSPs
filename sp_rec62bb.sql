-- Procedimiento que Carga la Descripcion de la Transaccion de Pago para los Accidentes Personales
-- Creado    : 28/05/2013 - Autor: Román Gordón

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

--drop procedure sp_rec62bb;		
create procedure sp_rec62bb(a_no_reclamo	char(10), a_no_tranrec	char(10))
returning	smallint;

define _nombre_recla	char(100);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _descripcion		char(100);
define _desc_acum		char(60);
define _no_documento	char(20);
define _numrecla		char(20);
define _fecha_siniestro	char(10);
define _cod_proveedor	char(10);
define _fecha_factura	char(10);
define _no_factura		char(10);
define _no_poliza		char(10);
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _cod_ocupacion	char(3);
define _monto			dec(16,2);
define _renglon			integer;
define _len_cadena2		smallint;
define _len_cadena		smallint;
define _cod_ramo        char(3);
define _cod_concepto    char(3);
define _n_concepto      char(50);

set isolation to dirty read;
--set debug file to "sp_rec62b.trc";
--trace on;

select count(*)
  into _renglon
  from rectrde2
 where no_tranrec = a_no_tranrec;

if _renglon is null then
	let _renglon = 0;
end if

if _renglon > 0 then
	return;
end if

select fecha_siniestro,
	   numrecla,
	   no_poliza,
	   cod_icd
  into _fecha_siniestro,
	   _numrecla,
	   _no_poliza,
	   _cod_icd
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_cpt,
	   cod_cliente,
	   monto
  into _cod_cpt,
	   _cod_proveedor,
	   _monto
  from rectrmae
 where no_tranrec = a_no_tranrec;

select no_documento,
       cod_ramo
  into _no_documento,
       _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select nombre,
	   cod_ocupacion
  into _nombre_recla,
	   _cod_ocupacion
  from cliclien
 where cod_cliente = _cod_proveedor;

if _cod_ocupacion = '004' then	--Medico 
	let _nombre_recla = 'AL DR. ' || trim(_nombre_recla);
else
	let _nombre_recla = 'A ' || trim(_nombre_recla);
end if
 
select nombre
  into _nombre_cpt
  from reccpt
 where cod_cpt = _cod_cpt;
 
select nombre
  into _nombre_icd
  from recicd
 where cod_icd = _cod_icd;
 
foreach
	select cod_concepto
	  into _cod_concepto
	  from rectrcon
	 where no_tranrec = a_no_tranrec
	exit foreach; 
end foreach

select nombre
  into _n_concepto
  from recconce
 where cod_concepto = _cod_concepto; 

let _renglon = 1;

let _descripcion = "MEDIANTE ESTA TRANSACCION SE REALIZA EL PAGO " || TRIM(_nombre_recla);
call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);
--return a_no_tranrec, _renglon, _descripcion with resume;

if _nombre_cpt is not null then

	let _renglon = _renglon + 1;
	if _desc_acum <> '' then
		let _descripcion = trim(_desc_acum) || " POR LA ATENCION:  " || TRIM(_nombre_cpt) || ' EL DÍA ' || TRIM(_fecha_siniestro) || '. ';
	else
		let _descripcion = "POR LA ATENCION  " || TRIM(_nombre_cpt) || ' EL DÍA ' || TRIM(_fecha_siniestro) || '.';
	end if
	
	let _desc_acum = '';
	call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;
	
	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _descripcion);
	--return a_no_tranrec, _renglon, _descripcion with resume;

end if

if _nombre_icd is not null then

	let _renglon = _renglon + 1;
	if _desc_acum <> '' then
		let _descripcion = trim(_desc_acum) || " DIAGNOSTICO: " || TRIM(_nombre_icd);
	else
		let _descripcion = "DIAGNOSTICO: " || TRIM(_nombre_icd);
	end if

	let _desc_acum = '';
	call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;

	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _descripcion);
	--return a_no_tranrec, _renglon, _descripcion with resume;
end if
if _cod_ramo = '016' then	--colectivo de vida
	if _n_concepto is not null then

		let _renglon = _renglon + 1;
		if _desc_acum <> '' then
			let _descripcion = trim(_desc_acum) || " POR EL CONCEPTO: " || TRIM(_n_concepto);
		else
			let _descripcion = "POR EL CONCEPTO: " || TRIM(_n_concepto);
		end if

		let _desc_acum = '';
		call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;

		insert into rectrde2(no_tranrec, renglon, desc_transaccion)
		values(a_no_tranrec, _renglon, _descripcion);
		--return a_no_tranrec, _renglon, _descripcion with resume;
	end if
end if
--****************************
let _renglon = _renglon + 1;
if _desc_acum <> '' then
	let _descripcion = trim(_desc_acum) || ", SE PROCEDE A PAGAR EN LA PÓLIZA #: " || TRIM(_no_documento) || " RECLAMO # " || TRIM(_numrecla);
else
	let _descripcion = ", SE PROCEDE A PAGAR EN LA PÓLIZA #: " || TRIM(_no_documento) || " RECLAMO # " || TRIM(_numrecla);
end if

let _desc_acum = '';
call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);
--return a_no_tranrec, _renglon, _descripcion with resume;

--
let _renglon = _renglon + 1;
if _desc_acum <> '' then
	let _descripcion = trim(_desc_acum) || " LA SUMA DE B/." || trim(cast(_monto as char(10)));
else
	let _descripcion = ". LA SUMA DE B/." || trim(cast(_monto as char(10)));
end if

let _desc_acum = '';
call sp_sis185(_descripcion,60) returning _descripcion,_desc_acum;

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);
--return a_no_tranrec, _renglon, _descripcion with resume;

if _desc_acum <> '' then
	let _renglon = _renglon + 1;
	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _desc_acum);
	--return a_no_tranrec, _renglon, _descripcion with resume;
end if
return 0;
end procedure
