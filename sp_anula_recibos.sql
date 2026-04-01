-- Procedure que Anula el Recibo y Crea  una Remesa con la misma información del recibo Anulado
-- Creado    : 10/02/2010 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_anula_recibos;
create procedure sp_anula_recibos(a_no_remesa char(10),a_crear_remesa smallint default 2, a_recibo1 char(10))
returning integer,
          char(100),
          char(10);

define _error_desc		char(100);
define _ult_no_recibo   char(10); 
define _no_remesa		char(10);
define _no_recibo    	char(10);
define _user_added      char(8);
define _cod_chequera 	char(3);
define _cod_cobrador    char(3);
define _error_isam		integer;
define _cantidad        integer;
define _error,_renglon			integer;

on exception set _error, _error_isam, _error_desc
   return _error, _error_desc,'';
end exception


SET ISOLATION TO DIRTY READ;

select cod_chequera,
	   cod_cobrador,
	   user_added
  into _cod_chequera,
	   _cod_cobrador,
	   _user_added
  from cobremae
 where no_remesa = a_no_remesa;--1310525


let _no_remesa = '00000';
let _ult_no_recibo = '00000';

begin
if a_crear_remesa = 1 then
	let _no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');

	select count(*)
	  into _cantidad
	  from cobremae
	 where no_remesa = _no_remesa;

	if _cantidad <> 0 then
		return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...','';
	end if

	--Hacer copia de la remesa actual
	--COBREMAE
	select * 
	  from cobremae
	 where no_remesa = a_no_remesa
	  into temp prueba;

	update prueba
	   set no_remesa = _no_remesa
	 where no_remesa = a_no_remesa;

	insert into cobremae
	select * from prueba
	 where no_remesa = _no_remesa;

	drop table prueba;

	--COBREDET
	select * 
	  from cobredet
	 where no_remesa = a_no_remesa
	  into temp prueba;

	update prueba
	   set no_remesa = _no_remesa,
		   no_recibo = a_recibo1,
		   doc_remesa = a_recibo1
	 where no_remesa = a_no_remesa;

	insert into cobredet
	select * from prueba
	 where no_remesa = _no_remesa;

	drop table prueba;

	--COBREAGT
	select * 
	  from cobreagt
	 where no_remesa = a_no_remesa
	  into temp prueba;

	update prueba
	   set no_remesa = _no_remesa
	 where no_remesa = a_no_remesa;

	insert into cobreagt
	select * from prueba
	 where no_remesa = _no_remesa;

	drop table prueba;

	--COBREPAG
	select * 
	  from cobrepag
	 where no_remesa = a_no_remesa
	  into temp prueba;

	update prueba
	   set no_remesa = _no_remesa
	 where no_remesa = a_no_remesa;

	insert into cobrepag
	select * from prueba
	 where no_remesa = _no_remesa;

	drop table prueba;
end if

---------------------------------
--Anulacion
update cobremae
   set monto_chequeo = 0,
       contar_recibos = 1,
	   recibi_de = 'ANULACION DE RECIBOS CAJA TECNICA DE SEG.'	--'ANULACION RECIBOS POR INUNDACION EL 09/04/2018'
 where no_remesa     = _no_remesa;

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = _no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

foreach
   select no_recibo
     into _no_recibo
	 from tmp_recibos

	if _no_recibo = a_recibo1 then
    else	
		let _renglon = _renglon + 1;	
		insert into cobredet(
				no_remesa,
				renglon,
				cod_compania,
				cod_sucursal,
				no_recibo,
				doc_remesa,
				tipo_mov,
				monto,
				prima_neta,
				impuesto,
				monto_descontado,
				comis_desc,
				desc_remesa,
				saldo,
				periodo,
				fecha,
				actualizado,
				no_poliza)
		values(
				_no_remesa,
				_renglon,
				'001',
				'010',
				_no_recibo,
				_no_recibo,
				'B',
				0,
				0,
				0,
				0,
				0,
				'',
				0,
				'2018-10',
				today,
				0,
				'');
		end if		

	update cobredet
	   set monto            = 0,
		   prima_neta       = 0,
		   impuesto		    = 0,
		   monto_descontado = 0,
		   desc_remesa      = "Anula Recibo " || _no_recibo,
		   saldo            = 0,
		   tipo_mov         = "B"
	 where no_remesa        = _no_remesa;
	 
end foreach	 

update cobrepag
   set importe = 0
 where no_remesa = _no_remesa;

delete from cobreagt
 where no_remesa = _no_remesa;

{call sp_cob29(a_no_remesa, _user_added) returning _error, _error_desc;
if _error <> 0 then
	return _error, _error_desc,'';
end if}

return 0, _no_recibo,_no_remesa;

end
end procedure 