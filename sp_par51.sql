-- Procedimiento que crea las tablas que seran utilizadas
-- para el proceso de verificacion de datos

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 16/02/2002 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_par51;

create procedure sp_par51() -- Create Table Verification

define _cantidad	smallint;

select count(*)
  into _cantidad
  from systables
 where tabname = "dbgfecha";

if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad <> 0 then
	drop table dbgfecha;
end if

create table dbgfecha(
	fecha		date,
	date_added	date,
	primary key (fecha)
	);

select count(*)
  into _cantidad
  from systables
 where tabname = "dbgdeta";

if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad <> 0 then
	drop table dbgdeta;
end if

create table dbgdeta(
	consecutivo		integer,
	fecha_dia		date,
	fecha_tran		date,
	no_poliza		char(10),
	no_endoso		char(5),
	no_remesa		char(10),
	renglon			smallint,
	no_requis		char(10),
	no_documento	char(20),
	monto			dec(16,2),
	tipo_tran       char(1),
	primary key 	(consecutivo)
	);

CREATE INDEX xie01_dbgdeta ON dbgdeta(no_poliza, no_endoso);
CREATE INDEX xie02_dbgdeta ON dbgdeta(no_remesa, renglon);
CREATE INDEX xie03_dbgdeta ON dbgdeta(no_requis, no_documento);

select count(*)
  into _cantidad
  from systables
 where tabname = "dbgacum";

if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad <> 0 then
	drop table dbgacum;
end if

create table dbgacum(
	fecha_tran		date,				
	monto_factura	dec(16,2),
	monto_pago	 	dec(16,2),
	monto_cheque 	dec(16,2),
	monto_anulado	dec(16,2),
	primary key 	(fecha_tran)
	);

-- Tabla que contiene los saldos por mes

select count(*)
  into _cantidad
  from systables
 where tabname = "dbgsaldo";

if _cantidad is null then
	let _cantidad = 0;
end if

if _cantidad <> 0 then
	drop table dbgsaldo;
end if

create table dbgsaldo(
   periodo          char(7),
   saldo            dec(16,2),
   primary key      (periodo)
   );

end procedure 