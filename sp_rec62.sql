-- Procedimiento que Carga la Descripcion de la Transaccion
-- de Pago para los Reclamos de Salud

-- Creado    : 09/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 09/01/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec62;		

CREATE PROCEDURE "informix".sp_rec62(
a_no_reclamo	char(10),
a_no_tranrec	char(10)
)

define _renglon			integer;

define _cod_reclamante	char(10);
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _fecha_siniestro	char(10);
define _numrecla		char(20);
define _no_poliza		char(10);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _no_documento	char(20);
define _nombre_recla	char(100);
define _descripcion		char(60);
define _fecha_factura	char(10);
define _no_factura		char(10);

SET ISOLATION TO DIRTY READ;

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

select cod_reclamante,
	   cod_icd,
	   fecha_siniestro,
	   numrecla,
	   no_poliza	
  into _cod_reclamante,
	   _cod_icd,
	   _fecha_siniestro,
	   _numrecla,
	   _no_poliza	
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_cpt,
	   no_factura,
	   fecha_factura	
  into _cod_cpt,
	   _no_factura,
	   _fecha_factura	
  from rectrmae
 where no_tranrec = a_no_tranrec;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = _no_poliza;

select nombre
  into _nombre_recla
  from cliclien
 where cod_cliente = _cod_reclamante;

select nombre
  into _nombre_cpt
  from reccpt
 where cod_cpt = _cod_cpt;

select nombre
  into _nombre_icd
  from recicd
 where cod_icd = _cod_icd;

let _renglon = 1;
let _descripcion = "RECLAMANTE: " || TRIM(_nombre_recla);

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);

if _nombre_cpt is not null then

	let _renglon = _renglon + 1;
	let _descripcion = "PROCEDIMIENTO: " || TRIM(_nombre_cpt);

	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _descripcion);

end if

let _renglon = _renglon + 1;
let _descripcion = "FECHA INCURRIDO: " || TRIM(_fecha_siniestro);

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);

if _nombre_icd is not null then

	let _renglon = _renglon + 1;
	let _descripcion = "DIAGNOSTICO: " || TRIM(_nombre_icd);

	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _descripcion);

end if

let _renglon = _renglon + 1;
let _descripcion = "POLIZA #: " || TRIM(_no_documento) || "     RECLAMO # " || TRIM(_numrecla);

insert into rectrde2(no_tranrec, renglon, desc_transaccion)
values(a_no_tranrec, _renglon, _descripcion);

if _fecha_factura is not null then
	if _no_factura is null then
	  let _no_factura = " ";
	end if
	let _renglon = _renglon + 1;
	let _descripcion = "FACTURA #: " || TRIM(_no_factura) || "     FECHA: " || TRIM(_fecha_factura);

	insert into rectrde2(no_tranrec, renglon, desc_transaccion)
	values(a_no_tranrec, _renglon, _descripcion);

end if

END PROCEDURE
