-- Reporte para las requisiciones de Reclamos de Auto por imprimir

-- Creado    : 12/07/2006 - Autor: Amado Perez

drop procedure sp_che103;

create procedure sp_che103()
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(50),
		   char(8),
		   char(8),
		   char(18),
		   char(8);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _numrecla        char(18);
define _user_added      char(8);

SET ISOLATION TO DIRTY READ;

foreach
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo in ('002', '020', '023')
 group by cod_banco, cod_chequera


	foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			user_added
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_user_added
	   from	chqchmae
	  where anulado       = 0
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and en_firma      = 2
		and origen_cheque <> "S"
--		and autorizado    = 1
		and pagado        = 0

	--	and cod_cliente   = "32659"

	 let _cod_tipopago = "";
	 let _numrecla     = "";
   --	 let _user_added   = "";

	 foreach
		select cod_tipopago, numrecla -- , user_added
		  into _cod_tipopago, _numrecla --, _user_added
		  from rectrmae
		 where no_requis   = _no_requis
		   and actualizado = 1
		exit foreach;
	 end foreach
	 
	 if _numrecla[1,2] not in ('02','20','23') then
		continue foreach;
	 end if
	   
	 select nombre
	   into _nom_tipopago
	   from rectipag
	  where cod_tipopago = _cod_tipopago;

		return _no_requis,
			   _cod_cliente,
			   _a_nombre_de,
			   _monto,
			   _periodo_pago,
			   _nom_tipopago,
			   _firma1,
			   _firma2,
			   _numrecla,  
			   _user_added
			   with resume;

	end foreach
end foreach
end procedure
