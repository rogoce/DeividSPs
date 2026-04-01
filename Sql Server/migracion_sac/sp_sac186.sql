-- Consulta de Movimientos de Cuentas Sac 
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac186('26612','REC061013','01/06/2010','sac')

DROP PROCEDURE sp_sac186;
CREATE PROCEDURE sp_sac186(a_cuenta char(12), a_compr char(15), a_fecha date, a_db CHAR(18)) 
RETURNING CHAR(12),		   -- cuenta  
		  CHAR(15),		   -- compr    
		  DATE,			   -- fecha    
		  DATE,			   -- fechatrx
		  CHAR(3),		   -- cia_nom	
		  CHAR(50),		   -- cia_nombre
		  CHAR(50),		   -- cta_nombre
		  DEC(16,2),	   -- debito   
		  DEC(16,2),	   -- credito
		  DEC(16,2),	   -- monto   
		  CHAR(10),		   -- no_requis
		  CHAR(12),		   -- origen	
		  INTEGER,		   -- notrx
		  char(255),	   -- datos
		  CHAR(7),		   -- periodo
		  CHAR(100),	   -- nom_recla
		  CHAR(20),		   -- doc_poliza
		  CHAR(3),		   -- cod_ramo
		  CHAR(100)		   -- desc_ramo

define _error			  integer;
define _error_desc		  char(50);
DEFINE 	_cia_nombre		  CHAR(50);
DEFINE 	_cia_nom		  CHAR(3);
DEFINE	_cta_nombre		  CHAR(50);
DEFINE	_origen			  CHAR(3);
DEFINE  _ocheque		  CHAR(1);
DEFINE	_debito			  DEC(16,2);
DEFINE	_credito		  DEC(16,2);
DEFINE	_no_tranrec		  CHAR(10);
DEFINE	_transaccion	  CHAR(10);
DEFINE	_periodo		  CHAR(7);
DEFINE	_no_requis		  CHAR(10);
DEFINE	_fecha			  DATE;
DEFINE	_monto			  DEC(16,2);
DEFINE	_no_reclamo		  CHAR(10);
DEFINE	_cod_proveedor	  CHAR(10);
DEFINE	_cuenta			  CHAR(12);
DEFINE	_compr     		  CHAR(15);
DEFINE	_fechatrx		  DATE;
DEFINE	_sac_notrx		  integer;
DEFINE	_notrx			  integer;
DEFINE	_cod_asegurado	  CHAR(10);
DEFINE	_cod_reclamante   CHAR(10);
DEFINE	_no_poliza        CHAR(10);
DEFINE	_cod_ramo         CHAR(3);
DEFINE	_cod_cliente      CHAR(10);
DEFINE	_doc_poliza       CHAR(20);
DEFINE	_cod_sucursal     CHAR(3);
DEFINE	_desc_ramo        CHAR(100);
DEFINE	_nom_recla        CHAR(100);
DEFINE	_n_proveedor      CHAR(100);
DEFINE	_nom_aseg		  CHAR(100);
DEFINE	_datos   		  CHAR(255);
DEFINE	v_nombre   		  CHAR(255);
DEFINE	_prima_neta		  DEC(16,2);

DEFINE	_fecha_impresion  DATE;
DEFINE	_fecha_anulado	  DATE;
DEFINE	_no_cheque		  integer;
DEFINE	_pagado		  	  integer;
DEFINE	_anulado		  integer;
DEFINE	s_no_cheque  	  CHAR(10);
DEFINE	_cod_banco  	  CHAR(5);
DEFINE	_tipo_requis  	  CHAR(5);
DEFINE	_numrecla    	  CHAR(18);
 
SET ISOLATION TO DIRTY READ;

let _datos = "";
let _transaccion = '';
let _numrecla = '';
let _no_poliza = '';

select cia_nom,cia_comp
  into _cia_nombre,_cia_nom
  from deivid:sigman02
 where cia_bda_codigo = a_db;

SELECT cta_nombre
  INTO _cta_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;

CREATE TEMP TABLE tmp_tran(
	    cuenta         CHAR(12),
		comp           CHAR(15),
		fecha          DATE,
		fecha_trx      DATE,
		cia_nom		   CHAR(50),
		cia_nombre     CHAR(50),
		cta_nombre     CHAR(100),
		debito         DEC(16,2) default 0,
		credito        DEC(16,2) default 0,
		monto          DEC(16,2) default 0,
		no_requis  	   CHAR(10),
		origen		   CHAR(12),
		sac_notrx      INTEGER,
		datos   	   char(255),
		periodo		   CHAR(7),
		nom_recla      CHAR(100),
		doc_poliza     CHAR(20),
		cod_ramo       CHAR(3),
		desc_ramo	   CHAR(100)
		) WITH NO LOG; 

CREATE TEMP TABLE tmp_detalle(
	    cuenta         CHAR(12),
		comp           CHAR(15),
		fecha          DATE,
		fecha_trx      DATE,
		cia_nom		   CHAR(50),
		cia_nombre     CHAR(50),
		cta_nombre     CHAR(100),
		debito         DEC(16,2) default 0,
		credito        DEC(16,2) default 0,
		monto          DEC(16,2) default 0,
		no_requis  	   CHAR(10),
		origen		   CHAR(12),
		sac_notrx      INTEGER,
		datos   	   char(255),
		periodo		   CHAR(7),
		nom_recla      CHAR(100),
		doc_poliza     CHAR(20),
		cod_ramo       CHAR(3),
		desc_ramo	   CHAR(100)
		) WITH NO LOG; 

-- set debug file to "sp_sac186.trc";	
-- trace on;
let _origen = "";

FOREACH
    select res_notrx,
    	   res_origen,
    	   res_debito,
    	   res_credito
	  into _notrx,
		   _origen,
		   _debito,
		   _credito
	  from cglresumen
	 where res_cuenta = a_cuenta
	   and res_comprobante = a_compr      
	   and res_fechatrx = a_fecha
	 order by res_comprobante,res_fechatrx,res_notrx	

		  if _origen = 'REC' then

			FOREACH
				select no_tranrec 
				  into _no_tranrec
				  from deivid:recasien 
				 where cuenta = a_cuenta 
				   and sac_notrx = _notrx

				FOREACH
				  select transaccion,
						 periodo,
						 no_requis,
						 fecha,
						 monto*-1,	   -- la 26612 afecta por el lado contrario. Xenia.
						 no_reclamo,
						 cod_proveedor
					into _transaccion,
						 _periodo,
						 _no_requis,
						 _fecha,
						 _monto,
						 _no_reclamo,
						 _cod_proveedor
				     from deivid:rectrmae
				    where cod_compania = "001"
				      and actualizado  = 1
				      and cod_tipotran = "004"
				      and no_tranrec   = _no_tranrec
				    order by fecha 

				   select cod_asegurado,
				  		  cod_reclamante,
						  no_poliza
					 into _cod_asegurado,
						  _cod_reclamante,
						  _no_poliza
					 from deivid:recrcmae
				    where no_reclamo = _no_reclamo;

				   select cod_ramo,
					      cod_contratante,
						  no_documento,
						  cod_sucursal
					 into _cod_ramo,
						  _cod_cliente,
						  _doc_poliza,
						  _cod_sucursal
					 from deivid:emipomae
				    where no_poliza = _no_poliza;

					 select nombre
					   into _desc_ramo
					   from deivid:prdramo
					  where cod_ramo = _cod_ramo;

					 select nombre
					   into _nom_recla
					   from deivid:cliclien
					  where cod_cliente = _cod_cliente;

					 select nombre
					   into _n_proveedor
					   from deivid:cliclien
					  where cod_cliente = _cod_proveedor;

					 select nombre
					   into _nom_aseg
					   from deivid:cliclien
					  where cod_cliente = _cod_asegurado;

--						LET _datos = "no.tran.rec.: "||_no_tranrec||" ,Transaccion: "||_transaccion;
						LET _datos = _transaccion;

					INSERT INTO tmp_tran(
							cuenta,       
							comp,         
							fecha,        
							fecha_trx,
							cia_nom,		 
							cia_nombre,       	 
							cta_nombre,   
							debito,       
							credito,      
							monto,         
							no_requis,  	 
							origen,		 
							sac_notrx,
							datos,
							periodo,
							nom_recla,
							doc_poliza,
							cod_ramo,
							desc_ramo)
					VALUES( a_cuenta,         
							a_compr,     
							a_fecha,    
							_fecha,
							_cia_nom,	
							_cia_nombre,
							_cta_nombre,
							_debito,   
							_credito,  
							_monto,    
							_no_requis,
							_origen,		
							_notrx,
							_datos,
							_periodo,
						    _nom_recla,
							_doc_poliza,
							_cod_ramo,
							_desc_ramo	) ;

				END FOREACH;
			END FOREACH;

		end if

		  if _origen = 'CHE' then
			LET _datos ="";
			LET _ocheque = "";
			FOREACH
				select distinct no_requis 
				  into _no_requis
				  from deivid:chqchcta 
				 where cuenta = a_cuenta 
				   and sac_notrx = _notrx

				FOREACH
					SELECT a.fecha_impresion,
					       a.no_cheque,
						   a.periodo,
						   a.pagado,
						   a.cod_banco,
						   a.anulado,
						   a.fecha_anulado,
						   a.tipo_requis,
						   a.cod_cliente,
						   b.debito - b.credito,   
						   a.a_nombre_de,          
						   a.origen_cheque
					  INTO _fecha_impresion,
						   _no_cheque,
						   _periodo,
						   _pagado,
						   _cod_banco,
						   _anulado,
						   _fecha_anulado,
						   _tipo_requis,
						   _cod_cliente,
						   _monto,
						   _nom_recla,
						   _ocheque
					  FROM deivid:chqchmae a, deivid:chqchcta b
					 WHERE a.en_firma  in (0,2)
					   AND a.no_requis = b.no_requis
--    				   AND a.origen_cheque in ("3","1")
					   AND a.no_requis = _no_requis			    					 
					   and b.cuenta = a_cuenta					   
					   and b.sac_notrx = _notrx

						if trim(_ocheque) = "3" then

					   		FOREACH
								SELECT transaccion,numrecla
								  INTO _transaccion,_numrecla
						  		  FROM deivid:chqchrec
						 		 WHERE no_requis = _no_requis
				 				  EXIT FOREACH;
						    END FOREACH

							      let _no_poliza = '';

					   		  FOREACH
							   SELECT no_poliza
						  		 INTO _no_poliza
					  		     FROM deivid:recrcmae
					 			WHERE transaccion = _transaccion
								  AND numrecla = _numrecla
				 				 EXIT FOREACH;
						    END FOREACH

							   select cod_ramo,
								      cod_contratante,
									  no_documento,
									  cod_sucursal
								 into _cod_ramo,
									  _cod_cliente,
									  _doc_poliza,
									  _cod_sucursal
								 from deivid:emipomae
							    where no_poliza = _no_poliza;

								 select nombre
								   into _desc_ramo
								   from deivid:prdramo
								  where cod_ramo = _cod_ramo;

						else
							 let _transaccion = '';
							 let _numrecla = '';
							 let _no_poliza = '';
							 let _cod_ramo = '';
							 let _cod_cliente = '';
							 let _doc_poliza = 'CONTABILIDAD';
							 let _cod_sucursal	= '';
							 let _desc_ramo = '';
						end if

							 if _anulado = 1 THEN
							    LET _monto = _monto ; --* -1;
								LET _fecha  = _fecha_anulado;
						   else
							    LET _monto = _monto;
								LET _fecha  = _fecha_impresion;
							end if
							LET s_no_cheque = _no_cheque;
--						    LET _datos = "no.cheque : "||s_no_cheque;
							LET _datos = s_no_cheque;

						INSERT INTO tmp_detalle(
								cuenta,       
								comp,         
								fecha,        
								fecha_trx,
								cia_nom,		 
								cia_nombre,       	 
								cta_nombre,   
								debito,       
								credito,      
								monto,         
								no_requis,  	 
								origen,		 
								sac_notrx,
								datos,
								periodo,
								nom_recla,
								doc_poliza,
								cod_ramo,
								desc_ramo)
						VALUES( a_cuenta,         
								a_compr,     
								a_fecha,    
								_fecha,
								_cia_nom,	
								_cia_nombre,
								_cta_nombre,
								_debito,   
								_credito,  
								_monto,    
								_no_requis,
								_origen,		
								_notrx,
								_datos,
								_periodo,
							    _nom_recla,
								_doc_poliza,
								_cod_ramo,
								_desc_ramo	) ;
				END FOREACH;
			END FOREACH;

		end if

END FOREACH;

if _origen = 'CHE' then
	FOREACH
	 SELECT cuenta,    
			comp,      
			fecha,     
			fecha_trx,
			cia_nom,	
			cia_nombre,
			cta_nombre,  
			no_requis, 
			origen,		
			datos,
			periodo,
			nom_recla,
			doc_poliza,
			cod_ramo,
			desc_ramo,
			sum(monto)
	   INTO _cuenta,   
			_compr,    
			_fecha,    
			_fechatrx,
			_cia_nom,	
			_cia_nombre,
			_cta_nombre,
			_no_requis,
			_origen,	
			_datos,
			_periodo,
			_nom_recla,
			_doc_poliza,
			_cod_ramo,
			_desc_ramo,
			_monto    
	    FROM tmp_detalle
	   group by cuenta,fecha,comp,fecha_trx,cia_nom,cia_nombre,cta_nombre,no_requis,origen,datos,periodo,nom_recla,doc_poliza,cod_ramo,desc_ramo
	   order by cuenta,fecha,comp,fecha_trx,cia_nom,cia_nombre,cta_nombre,no_requis,origen,datos,periodo,nom_recla,doc_poliza,cod_ramo,desc_ramo



			 INSERT INTO tmp_tran(
					cuenta,       
					comp,         
					fecha,        
					fecha_trx,
					cia_nom,		 
					cia_nombre,       	 
					cta_nombre,   
					debito,       
					credito,      
					monto,         
					no_requis,  	 
					origen,		 
					sac_notrx,
					datos,
					periodo,
					nom_recla,
					doc_poliza,
					cod_ramo,
					desc_ramo)
			VALUES( a_cuenta,         
					a_compr,     
					a_fecha,    
					_fecha,
					_cia_nom,	
					_cia_nombre,
					_cta_nombre,
					0,   
					0,  
					_monto,    
					_no_requis,
					_origen,		
					0,
					_datos,
					_periodo,
				    _nom_recla,
					_doc_poliza,
					_cod_ramo,
					_desc_ramo	) ;


	END FOREACH;

end if

FOREACH	
  SELECT cuenta,    
		comp,      
		fecha,     
		fecha_trx,
		cia_nom,	
		cia_nombre,
		cta_nombre,
		debito,    
		credito,   
		monto,     
		no_requis, 
		origen,		
		sac_notrx,
		datos,
		periodo,
		nom_recla,
		doc_poliza,
		cod_ramo,
		desc_ramo
   INTO _cuenta,   
		_compr,    
		_fecha,    
		_fechatrx,
		_cia_nom,	
		_cia_nombre,
		_cta_nombre,
		_debito,   
		_credito,  
		_monto,    
		_no_requis,
		_origen,	
		_notrx,
		_datos,
		_periodo,
		_nom_recla,
		_doc_poliza,
		_cod_ramo,
		_desc_ramo
    FROM tmp_tran
   order by fecha, comp, fecha_trx

	
  RETURN _cuenta,   
	     _compr,    
		 _fecha,    
		 _fechatrx,
		 _cia_nom,	
	     _cia_nombre,
		 _cta_nombre,
		 _debito,   
		 _credito,  
		 _monto,    
		 _no_requis,
		 _origen,	
		 _notrx,
		 _datos,
		 _periodo,
		 _nom_recla,
		 _doc_poliza,
		 _cod_ramo,
		 _desc_ramo		 		 
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_tran;
DROP TABLE tmp_detalle;

END PROCEDURE					 
						 




 		  