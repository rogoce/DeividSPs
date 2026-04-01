-- procedimiento realiza el cambio gestor por motivo
-- creado    : 24/01/2012 - autor: henry giron.
-- Modificado: 08/05/2015 - Autor: Román Gordón - Agregar la excepción si no se encuentra la Firma del Supervisor del Usuario al que se le transfieren los datos.
-- sis v.2.0 - deivid, s.a.  -- execute procedure sp_sis396('GISELA','SMORCILL','01058')

drop procedure sp_sis396;
create procedure "informix".sp_sis396(
a_cob_vjo	char(3),
a_cob_nvo	char(3),
a_aviso		char(10))
returning integer,
		  varchar(150);

define _mensaje				varchar(150);
define _cargo_supervisor	varchar(50);
define _nom_supervisor		varchar(50);
define _cargo_gestor		varchar(50);
define _nom_gestor			varchar(50);
define _usuario_supervisor	char(8);
define _usuario_gestor		char(8);
define a_nvo				char(8);
define a_vjo				char(8);
define _cod_supervisor		char(3);
define _cod_gestor			char(3);
define _tm_ultima_gestion	integer;
define _tm_fecha_efectiva	integer;
define _error_2				integer;
define _error				integer;
define _return				smallint;

 --set debug file to "sp_sis396.trc";
 --trace on;   

set isolation to dirty read;
Let _mensaje = 'Reasignacion de Gestor...';
let _error = 0;

begin
on exception set _error, _error_2, _mensaje 
 	return _error, _mensaje;
end exception  

select trim(usuario)
  into a_vjo
  from cobcobra
 where cod_cobrador = a_cob_vjo  
   and activo = 1;

select trim(usuario)
  into a_nvo
  from cobcobra
 where cod_cobrador = a_cob_nvo  
   and activo = 1;

let _tm_ultima_gestion = 0;
let _tm_fecha_efectiva = 0;

select tm_ultima_gestion,
	   tm_fecha_efectiva
  into _tm_ultima_gestion,
	   _tm_fecha_efectiva
  from parparam;

if _tm_fecha_efectiva is null then
	let _tm_fecha_efectiva = 15;
end if

if _tm_ultima_gestion is null then
	let _tm_ultima_gestion = 2;
end if

call sp_sis154(a_nvo) 
returning	_cod_supervisor,
			_nom_supervisor,
			_usuario_supervisor,
			_cargo_supervisor,
			_cod_gestor,
			_nom_gestor,
			_usuario_gestor,
			_cargo_gestor; 

if _usuario_supervisor is null or _usuario_supervisor = '' then
	let _mensaje = 'No se encontró Usuario para la Firma2. Verifique el Supervisor del Usuario (' || trim(_cod_gestor)  || ') ' || trim(_nom_gestor);
	return 1,_mensaje;
end if

update avicanpar
   set user_added = a_nvo,
	   tm_ultima_gestion = _tm_ultima_gestion,
	   tm_fecha_efectiva = _tm_fecha_efectiva,
	   usuario1 = a_nvo,
	   usuario2 = _usuario_supervisor,
	   nombre1 = _nom_gestor,
	   nombre2 = _nom_supervisor,
	   cargo2 = _cargo_supervisor,	
	   cargo1 = _cargo_gestor
  where user_added = a_vjo
    and cod_avican = a_aviso;

if _error <> 0 then
    let _mensaje = "Fallo de Reasignacion - Parametros...";
	return _error, _mensaje;
end if

update avicanbit 
   set usuario = a_nvo 
 where usuario = a_vjo
   and no_aviso = a_aviso;

if _error <> 0 then
    let _mensaje = "Fallo de Reasignacion - Bitacora...";
	return _error, _mensaje;
end if

update avisocanc 
   set user_proceso = a_nvo,
	   usuario1 = a_nvo,
	   usuario2 = _usuario_supervisor,	   
	   nombre1 = _nom_gestor,
	   nombre2 = _nom_supervisor,
	   cargo2 = _cargo_supervisor,
	   cargo1 = _cargo_gestor
 where no_aviso = a_aviso;

if _error <> 0 then
    let _mensaje = "Fallo de Reasignacion - Gestion de Aviso...";
	return _error, _mensaje;
end if
end
return 0, "Actualizacion Exitosa ...";
--trace off;
end procedure;