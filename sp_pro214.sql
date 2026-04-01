-- Reporte para buscar la devolucion de una evaluacion

-- Creado    : 31/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro214;
CREATE PROCEDURE sp_pro214(a_no_evaluacion char(10))
returning char(10),varchar(100),smallint,char(11),decimal(16,2),date,date,integer,char(11),smallint;


define _n_contratante    varchar(100);
define _nom_tipo_ramo	 char(15);
define _no_evaluacion	 char(10);
define _fecha			 datetime year to fraction(5);
define _no_recibo		 char(11);
define _no_recibo_c      char(10);
define _fecha_recibo	 date;
define _monto			 decimal(16,2);
define _cantidad	     integer;
define _cod_asegurado    char(10);
define _cod_producto     char(5);
define _es_medico        smallint;
define _fecha_eval       date;
define _fecha_hora       datetime hour to fraction(5);
define _decicion,_cnt    smallint;
define _suspenso         smallint;
define _completado       smallint;
define _tipo_ramo		 smallint;
define _usuario_eval     char(8);
define _fecha_compl		 date;
define _n_decicion       char(20);
define _pagado           smallint;
define _fecha_impresion  date;
define _no_cheque        integer;
define _monto_cheque     dec(16,2);
define _no_requis        char(10);
define _doc_remesa		 char(20);
define _n_suspenso       varchar(50);


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_pro206.trc";
--trace on;

--SET LOCK MODE TO WAIT;

BEGIN

let _n_decicion = "";
let _monto      = 0;
let _doc_remesa   = sp_sis15('CPDEVSUS');
let _no_recibo_c = '';
let _pagado = 0;

	SELECT no_evaluacion,
		   cod_contratante,
		   decicion,
		   suspenso,
		   completado,
		   usuario_eval,
		   tipo_ramo,
		   no_recibo,
		   date(fecha_completado),
		   monto
	  INTO _no_evaluacion,
		   _cod_asegurado,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _tipo_ramo,
		   _no_recibo,
		   _fecha_compl,
		   _monto
	  FROM emievalu
	 WHERE no_evaluacion = a_no_evaluacion;

	if _decicion in(3,8) then	--declina ancon,desiste cliente

		select count(*)
		  into _cnt
		  from cobredet
		 where no_recibo = _no_recibo
	       and tipo_mov  = 'M';

		if _cnt = 0 then
		    foreach
				select no_recibo
				  into _no_recibo_c
				  from cobredet
				 where doc_remesa = _no_recibo
				   and tipo_mov   = 'E'
				   and monto      = _monto
				   exit foreach;
			end foreach
			select count(*)
			  into _cnt
			  from cobredet
			 where no_recibo = _no_recibo_c
			   and tipo_mov  = 'M';
		end if

		if _cnt > 0 then
			select count(*)
			  into _cnt
			  from chqchmae
			 where cod_cliente   = _cod_asegurado
			   and origen_cheque = 'S'
			   and fecha_captura = _fecha_compl;
			   
            if _cnt > 0 then
				foreach
					select pagado,
						   fecha_impresion,
						   no_cheque,
						   monto,
						   no_requis
					  into _pagado,
						   _fecha_impresion,
						   _no_cheque,
						   _monto_cheque,
						   _no_requis
					  from chqchmae
					 where cod_cliente   = _cod_asegurado
					   and origen_cheque = 'S'
					   and fecha_captura = _fecha_compl

					exit foreach;
				end foreach

				select nombre
				  into _n_contratante
				  from cliclien
				 where cod_cliente = _cod_asegurado;

				Return _no_evaluacion,
					   _n_contratante,
					   _decicion,
					   _no_recibo,
					   _monto_cheque,
					   _fecha_impresion,
					   _fecha_compl,
					   _no_cheque,
					   _no_requis,
					   _pagado
						with resume;
			else
				foreach
					select trim(desc_remesa)
					  into _n_suspenso
					  from cobredet
					 where no_recibo = _no_recibo_c
                       and tipo_mov  = 'M'	
                       and monto      = _monto					   
					exit foreach;
                end foreach					
					 
				foreach
					select pagado,
						   fecha_impresion,
						   no_cheque,
						   monto,
						   no_requis
					  into _pagado,
						   _fecha_impresion,
						   _no_cheque,
						   _monto_cheque,
						   _no_requis
					  from chqchmae
					 where trim(a_nombre_de) = trim(_n_suspenso)
					   and origen_cheque = 'S'
					   and fecha_captura = _fecha_compl
					   and monto = _monto

					exit foreach;
				end foreach

				Return _no_evaluacion,
					   _n_suspenso,
					   _decicion,
					   _no_recibo,
					   _monto_cheque,
					   _fecha_impresion,
					   _fecha_compl,
					   _no_cheque,
					   _no_requis,
					   _pagado
						with resume;					 
			end if
		end if

	end if
END
END PROCEDURE
