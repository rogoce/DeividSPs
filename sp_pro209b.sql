--Proceso Control firma Emision
--Procedure que retorna el usuario para enviar a workflow
--Armando Moreno 16/05/2011

DROP PROCEDURE sp_pro209b;

CREATE PROCEDURE "informix".sp_pro209b(a_cod_ramo CHAR(3),a_suma integer,a_fac_front smallint DEFAULT 0, a_cod_suc char(3))
RETURNING CHAR(8),CHAR(30),smallint,char(30),char(1),smallint;


define _usuario      char(8);
define _windows_user char(30);
define _limite1 	 dec(16,2);
define _cod_perfil   char(3);
define _status       char(1);
define _correo_vice  char(30);
define _usuario_bk   char(8);
define _valor        integer;
define _emis_firma_aut smallint;

SET ISOLATION TO DIRTY READ;

begin

ON EXCEPTION IN(-206)
END EXCEPTION

drop table tmp_user;
end

BEGIN

--set debug file to "sp_pro209b.trc";
--trace on;


let _correo_vice = "";
let _usuario_bk  = "";

if a_fac_front = 1 then	 --si es fac o fronting va directo a buscar al gerente tecnico.
	
	if a_cod_ramo in ('020','018') then
		let a_fac_front = 0;
	end if
	
	select cod_perfil
	  into _cod_perfil
	  from wf_cfelim
	 where cod_ramo        = a_cod_ramo
	   and facult_fronting = a_fac_front;

	call sp_pro210(_cod_perfil) returning _valor; --buscar usuario Gerencia tecnica

	select count(*)
	  into _valor
	  from tmp_user
	 where status = "A";

	if _valor > 0 then	--existen activos

		if _cod_perfil = '002' then --GTPatrimoniales
			  foreach
				select e_mail
				  into _correo_vice
				  from insuser
				 where cod_perfil_wf_emis = "006"  --"005" --VicePresidencia Patrimoniales. se cambia por que no Hay persona en este cargo 15/04/2014
				exit foreach;
			  end foreach
		else
			  foreach
				select e_mail
				  into _correo_vice
				  from insuser
				 where cod_perfil_wf_emis = "006" --Vicepresidente Ejecutivo
				exit foreach;
			  end foreach
		end if
		foreach
	
			select windows_user,
			       usuario,
				   status,
				   emis_firma_aut
			  into _windows_user,
			       _usuario,
				   _status,
				   _emis_firma_aut
			  from tmp_user

			RETURN _usuario,_windows_user,0,_correo_vice,_status,_emis_firma_aut with resume;

		end foreach

		--drop table tmp_user;
	else	  --Ninguno activo, paso al siguiente nivel

	    if _cod_perfil = '002' then --GTPatrimoniales
			drop table tmp_user;
			call sp_pro210('005') returning _valor; --buscar VPPatrimoniales

			select count(*)
			  into _valor
			  from tmp_user
			 where status = "A";

			if _valor > 0 then

				foreach

					select windows_user,
					       usuario,
						   status,
						   emis_firma_aut
					  into _windows_user,
					       _usuario,
						   _status,
						   _emis_firma_aut
					  from tmp_user

					RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

				end foreach

				--drop table tmp_user;
				
			else
				drop table tmp_user;
				call sp_pro210('006') returning _valor; --buscar VPEjecutiva

				select count(*)
				  into _valor
				  from tmp_user
				 where status = "A";

				if _valor > 0 then

					foreach

						select windows_user,
						       usuario,
							   status,
							   emis_firma_aut
						  into _windows_user,
						       _usuario,
							   _status,
							   _emis_firma_aut
						  from tmp_user

						RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

					end foreach

					--drop table tmp_user;

				else
					select valor_parametro
					  into _usuario_bk
					  from inspaag
					 where codigo_parametro = 'firma_backup'
					   and aplicacion       = 'PRO';

					drop table tmp_user;
					call sp_pro210('001',2,_usuario_bk) returning _valor; --buscar firma usuario backup

					select count(*)
					  into _valor
					  from tmp_user
					 where status = "A";

					if _valor > 0 then

						foreach

							select windows_user,
							       usuario,
								   status,
								   emis_firma_aut
							  into _windows_user,
							       _usuario,
								   _status,
								   _emis_firma_aut
							  from tmp_user

							RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

						end foreach

					   --	drop table tmp_user;

					else
						drop table tmp_user;
						RETURN 'ERROR','ERROR',2,"","",0;
					end if
				end if
			end if
		else
		
			if a_cod_ramo = '008' then
				RETURN '','',2,"","",0;
			end if
			
			drop table tmp_user;
			
			call sp_pro210('006') returning _valor; --buscar VPEjecutiva

			select count(*)
			  into _valor
			  from tmp_user
			 where status = "A";

			if _valor > 0 then

				foreach

					select windows_user,
					       usuario,
						   status,
						   emis_firma_aut
					  into _windows_user,
					       _usuario,
						   _status,
						   _emis_firma_aut
					  from tmp_user

					RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

				end foreach

				--drop table tmp_user;

			else
				select valor_parametro
				  into _usuario_bk
				  from inspaag
				 where codigo_parametro = 'firma_backup'
				   and aplicacion       = 'PRO';

				drop table tmp_user;
				call sp_pro210('001',2,_usuario_bk) returning _valor; --buscar firma usuario backup

				select count(*)
				  into _valor
				  from tmp_user
				 where status = "A";

				if _valor > 0 then

					foreach

						select windows_user,
						       usuario,
							   status,
							   emis_firma_aut
						  into _windows_user,
						       _usuario,
							   _status,
							   _emis_firma_aut
						  from tmp_user

						RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

					end foreach

					--drop table tmp_user;

				else
					drop table tmp_user;
					RETURN 'ERROR','ERROR',2,"","",0;
				end if

			end if
		end if
	end if
else

	if a_fac_front = 2 then	 --Esto se es para cuando son colectivos
		let a_suma = 150000;
	end if

	--para saber si los limites son menores.
	select limite1
	  into _limite1
	  from wf_cfelim
	 where cod_ramo        = a_cod_ramo
	   and facult_fronting = 0;

	if a_suma < _limite1 then
		
		if a_fac_front = 3 then	--Esto es para cuando es subramo FranceField o ZonaLibre
			let a_suma = 500000;
		else 
			RETURN "","",1,"","",0;
		end if
	end if

	--buscar por limites de suma asegurada
	select cod_perfil
	  into _cod_perfil
	  from wf_cfelim
	 where cod_ramo = a_cod_ramo
	   and a_suma between limite1 and limite2;

	call sp_pro210(_cod_perfil) returning _valor; --buscar Sub Gerencia T. de Emision. o GT

	select count(*)
	  into _valor
	  from tmp_user
	 where status = "A";

	if _valor > 0 then

		foreach

			select windows_user,
			       usuario,
				   status,
				   emis_firma_aut
			  into _windows_user,
			       _usuario,
				   _status,
				   _emis_firma_aut
			  from tmp_user

			RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

		end foreach

		drop table tmp_user;

	else
		select cod_perfil
		  into _cod_perfil
		  from wf_cfelim
		 where cod_ramo        = a_cod_ramo
		   and facult_fronting = 1;

		drop table tmp_user;
		call sp_pro210(_cod_perfil) returning _valor; --buscar usuario Gerencia tecnica

		select count(*)
		  into _valor
		  from tmp_user
		 where status = "A";

		if _valor > 0 then

			foreach

				select windows_user,
				       usuario,
					   status,
					   emis_firma_aut
				  into _windows_user,
				       _usuario,
					   _status,
					   _emis_firma_aut
				  from tmp_user

				RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

			end foreach

			drop table tmp_user;

		else
		    if _cod_perfil = '002' then --GTPatrimoniales
				drop table tmp_user;
				call sp_pro210('005') returning _valor; --buscar VPPatrimoniales

				select count(*)
				  into _valor
				  from tmp_user
				 where status = "A";

				if _valor > 0 then
					foreach

						select windows_user,
						       usuario,
							   status,
							   emis_firma_aut
						  into _windows_user,
						       _usuario,
							   _status,
							   _emis_firma_aut
						  from tmp_user

						RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

					end foreach

					drop table tmp_user;

				else
					drop table tmp_user;
					call sp_pro210('006') returning _valor; --buscar VPEjecutiva

					select count(*)
					  into _valor
					  from tmp_user
					 where status = "A";

					if _valor > 0 then

						foreach

							select windows_user,
							       usuario,
								   status,
								   emis_firma_aut
							  into _windows_user,
							       _usuario,
								   _status,
								   _emis_firma_aut
							  from tmp_user

							RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

						end foreach

						drop table tmp_user;
					else
						select valor_parametro
						  into _usuario_bk
						  from inspaag
						 where codigo_parametro = 'firma_backup'
						   and aplicacion       = 'PRO';

						drop table tmp_user;
						call sp_pro210('001',2,_usuario_bk) returning _valor; --buscar firma usuario backup

						select count(*)
						  into _valor
						  from tmp_user
						 where status = "A";

						if _valor > 0 then

							foreach

								select windows_user,
								       usuario,
									   status,
									   emis_firma_aut
								  into _windows_user,
								       _usuario,
									   _status,
									   _emis_firma_aut
								  from tmp_user

								RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

							end foreach

							drop table tmp_user;

						else
							drop table tmp_user;
							RETURN 'ERROR','ERROR',2,"","",0;
						end if

					end if
				end if
			else
				drop table tmp_user;
				call sp_pro210('006') returning _valor; --buscar VPEjecutiva

				select count(*)
				  into _valor
				  from tmp_user
				 where status = "A";

				if _valor > 0 then

					foreach

						select windows_user,
						       usuario,
							   status,
							   emis_firma_aut
						  into _windows_user,
						       _usuario,
							   _status,
							   _emis_firma_aut
						  from tmp_user

						RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

					end foreach

					drop table tmp_user;

				else
					select valor_parametro
					  into _usuario_bk
					  from inspaag
					 where codigo_parametro = 'firma_backup'
					   and aplicacion       = 'PRO';

					drop table tmp_user;
					call sp_pro210('001',2,_usuario_bk) returning _valor; --buscar firma usuario backup

					select count(*)
					  into _valor
					  from tmp_user
					 where status = "A";

					if _valor > 0 then

						foreach

							select windows_user,
							       usuario,
								   status,
								   emis_firma_aut
							  into _windows_user,
							       _usuario,
								   _status,
								   _emis_firma_aut
							  from tmp_user

							RETURN _usuario,_windows_user,0,"",_status,_emis_firma_aut with resume;

						end foreach

						drop table tmp_user;
					else
						RETURN 'ERROR','ERROR',2,"","",0;
					end if
				end if
			end if
		end if
	end if
end if

END

begin

ON EXCEPTION IN(-206)
END EXCEPTION

drop table tmp_user;
end

END PROCEDURE;