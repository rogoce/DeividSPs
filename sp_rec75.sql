-- Requisiciones de Cheques desde Reclamos
-- Crea la descripcion de la requisicion con el nuevo formato de que
-- se pueden generar para la misma requisicion transacciones de la misma 
-- persona pero de diferentes reclamos.

-- Creado    : 15/10/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/10/2003 - Autor: Demetrio Hurtado Almanza

drop procedure sp_rec75;

create procedure "informix".sp_rec75(
a_transaccion	char(10),
a_no_requis		char(10)
) returning integer,
            char(100);

define a_no_reclamo		char(10);
define _cod_reclamante	char(10);
define _fecha_siniestro	char(10);
define _numrecla		char(20);
define _no_poliza		char(10);
define _no_documento	char(20);
define _nombre_recla	char(100);
define _descripcion		char(100);

define _cantidad		integer;

--set debug file to "sp_rec75.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

let _cantidad = 0;

select count(*)
  into _cantidad
  from chqchdes
 where no_requis = a_no_requis;

if _cantidad = 0 then
	
	-- Espacios en Blanco

	let _descripcion = "";

	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	a_no_requis,
	1,
	_descripcion
	);

	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	a_no_requis,
	2,
	_descripcion
	);

	-- Encabezado de lo que se Paga

	let _descripcion = "POLIZA                 RECLAMO                SINIESTRO   RECLAMANTE";

	insert into chqchdes(
	no_requis,
	renglon,
	desc_cheque
	)
	values(
	a_no_requis,
	3,
	_descripcion
	);

	let _cantidad = 3;

else

	select desc_cheque
	  into _descripcion
	  from chqchdes
	 where no_requis = a_no_requis
	   and renglon   = 1;

	if _descripcion <> "" then
		return 1, "A las Requisiciones Viejas No se le Pueden Agregar Transacciones";
	End if
	
end if

let _cantidad = _cantidad + 1;

if _cantidad > 30 then
	return 1, "No se Pueden Agregar Mas Transacciones a esta Requisicion";
end if

select no_reclamo
  into a_no_reclamo
  from rectrmae
 where transaccion = a_transaccion;

select cod_reclamante,
	   fecha_siniestro,
	   numrecla,
	   no_poliza	
  into _cod_reclamante,
	   _fecha_siniestro,
	   _numrecla,
	   _no_poliza	
  from recrcmae
 where no_reclamo = a_no_reclamo;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = _no_poliza;

select nombre
  into _nombre_recla
  from cliclien
 where cod_cliente = _cod_reclamante;

let _descripcion         = "";
let _descripcion[1,15]   = _no_documento;
let _descripcion[18,34]  = _numrecla;
let _descripcion[37,47]  = _fecha_siniestro;
let _descripcion[50,100] = _nombre_recla;

insert into chqchdes(
no_requis,
renglon,
desc_cheque
)
values(
a_no_requis,
_cantidad,
_descripcion
);

return 0, "Actualizacion Exitosa ...";

end procedure;
