----------------------------------------------------------
--Proceso que hace el cambio de productos en la renovación automática de las pólizas cuya suma asegurada 
--está por debajo del minímo del producto que posee actualmente.
--Creado : 08/03/2016 - Autor: Román Gordón
--ref. deivid: d_prod_sp_pro383_dw1
--SIS v.2.0 - DEIVID, S.A.
----------------------------------------------------------

--execute procedure sp_pro383('001','001','2016-02','2016-02','*','002,020,023;','*','*','*','*',0,'*','*',0,'*','*','*')
drop procedure sp_cob384;
create procedure sp_cob384()
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _cadena				varchar(255);
define _valor_cadena		varchar(50);
define _motivo_rechazo		varchar(30);
define _no_lote				char(5);
define _char				char(1);
define _ind_motivo_rech		smallint;
define _ind_renglon			smallint;
define _ind_lote			smallint;
define _procesar			smallint;
define _renglon				smallint;
define _indice				smallint;
define _error_isam			integer;
define _len_cadena			integer;
define _error				integer;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_pro383.trc";
--trace on;

delete from cobamex
 where campo is null;

update cobtatra
   set procesar = 0;

select indice
  into _ind_lote
  from cobforamex
 where campo = 'no_lote';

select indice
  into _ind_renglon
  from cobforamex
 where campo = 'renglon';

select indice
  into _ind_motivo_rech
  from cobforamex
 where campo = 'motivo_rechazo';

foreach
	select campo || ';'
	  into _cadena
	  from cobamex

	call sp_sis04d(_cadena) returning _char;

	let _no_lote = '00000';
	let _renglon = 0;

	foreach
		select indice,
			   substr(_cadena,pos,ancho_cadena)
		  into _indice,
			   _valor_cadena
		  from tmp_codigos
		 order by indice

		if _indice = 1 then
			if _valor_cadena = 'TRANSACCIONES EXITOSAS' then
				let _procesar = 1;
			elif _valor_cadena = 'TRANSACCIONES FALLIDAS' then
				let _procesar = 0;
			elif upper(_valor_cadena) <> 'VENTA' then
				exit foreach;
			end if
		elif _indice = _ind_lote then
			let _no_lote = _valor_cadena;
		elif _indice = _ind_renglon then
			let _renglon = _valor_cadena;
		elif _indice = _ind_motivo_rech then
			let _motivo_rechazo = _valor_cadena;
		end if
	end foreach

	update cobtatra
	   set procesar = _procesar,
		   motivo_rechazo = _motivo_rechazo
	 where no_lote = _no_lote
	   and renglon = _renglon;
end foreach

drop table if exists tmp_codigos;

return 0,'Actualización Exitosa.';

end
end procedure;