// =====================================================
// EMAIL TEMPLATES FOR ASSERO FOUNDERS CIRCLE
// =====================================================

const emailTemplates = {
  // Template for user confirmation
  userConfirmation: (application) => {
    const timestamp = new Date().toLocaleString('de-DE');
    return {
      subject: '✅ Bewerbung erfolgreich eingereicht - Assero Founders Circle',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #c7a770, #2c3e50); color: white; padding: 30px; text-align: center; border-radius: 12px 12px 0 0;">
            <h1 style="margin: 0; font-size: 28px;">✅ Bewerbung eingegangen!</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Ihre Founders Circle Bewerbung wurde erfolgreich übermittelt</p>
          </div>
          
          <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 12px 12px; border: 1px solid #e9ecef;">
            <h2 style="color: #2c3e50; margin-top: 0;">Vielen Dank, ${application.first_name}!</h2>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #28a745;">
              <p style="margin: 0; color: #155724; font-weight: 600; font-size: 16px;">
                ✅ Ihre Bewerbung für den Assero Founders Circle wurde erfolgreich eingereicht!
              </p>
            </div>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3 style="color: #2c3e50; margin-top: 0;">📋 Ihre Bewerbungsdetails:</h3>
              <ul style="color: #555; line-height: 1.8;">
                <li><strong>Name:</strong> ${application.first_name} ${application.last_name}</li>
                <li><strong>Email:</strong> ${application.email}</li>
                <li><strong>Unternehmen:</strong> ${application.company || 'Nicht angegeben'}</li>
                <li><strong>Position:</strong> ${application.role}</li>
              </ul>
            </div>
            
            <div style="background: #e8f5e8; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #c3e6c3;">
              <h3 style="color: #2d5a2d; margin-top: 0;">⏰ Nächste Schritte:</h3>
              <ul style="color: #2d5a2d; line-height: 1.8;">
                <li><strong>Prüfung:</strong> Unser Team prüft Ihre Bewerbung sorgfältig</li>
                <li><strong>Entscheidung:</strong> Sie erhalten innerhalb von 24 Stunden eine Rückmeldung</li>
                <li><strong>Persönliches Gespräch:</strong> Bei positiver Entscheidung vereinbaren wir ein Gespräch</li>
                <li><strong>Onboarding:</strong> Einführung in die exklusive Founders Circle Community</li>
              </ul>
            </div>
            
            <div style="background: #fff3cd; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #ffeaa7;">
              <h3 style="color: #856404; margin-top: 0;">💡 Während Sie warten:</h3>
              <p style="color: #856404; line-height: 1.6;">
                Besuchen Sie <a href="https://assero.io" style="color: #c7a770; font-weight: 600;">assero.io</a> 
                und informieren Sie sich über unsere Plattform und die verfügbaren Asset-Kategorien.
              </p>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
              <a href="mailto:assero@assero.io" 
                 style="background: #c7a770; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block;">
                 📧 Fragen? Kontaktieren Sie uns
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px; color: #6c757d; font-size: 12px;">
            <p>Assero.io - Die Plattform für exklusive Asset-Investments</p>
            <p>Zeitstempel: ${timestamp}</p>
          </div>
        </div>
      `
    };
  },

  // Template for approved applications
  approved: (application) => {
    const timestamp = new Date().toLocaleString('de-DE');
    return {
      subject: '🎉 Willkommen im Assero Founders Circle!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #c7a770, #2c3e50); color: white; padding: 30px; text-align: center; border-radius: 12px 12px 0 0;">
            <h1 style="margin: 0; font-size: 28px;">🎯 Willkommen im Founders Circle!</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Ihre Bewerbung wurde genehmigt</p>
          </div>
          
          <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 12px 12px; border: 1px solid #e9ecef;">
            <h2 style="color: #2c3e50; margin-top: 0;">Herzlichen Glückwunsch, ${application.first_name}!</h2>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #28a745;">
              <p style="margin: 0; color: #155724; font-weight: 600; font-size: 16px;">
                ✅ Ihre Bewerbung für den Assero Founders Circle wurde erfolgreich genehmigt!
              </p>
            </div>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3 style="color: #2c3e50; margin-top: 0;">🎯 Nächste Schritte:</h3>
              <ul style="color: #555; line-height: 1.8;">
                <li><strong>Persönliches Gespräch:</strong> Wir werden uns innerhalb von 24 Stunden bei Ihnen melden</li>
                <li><strong>Onboarding:</strong> Einführung in die Assero-Plattform und Community</li>
                <li><strong>Exklusive Features:</strong> Early Access zu neuen Funktionen</li>
                <li><strong>Networking:</strong> Einladung zu exklusiven Events</li>
              </ul>
            </div>
            
            <div style="background: #e8f5e8; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #c3e6c3;">
              <h3 style="color: #2d5a2d; margin-top: 0;">🏆 Ihre Vorteile im Founders Circle:</h3>
              <ul style="color: #2d5a2d; line-height: 1.8;">
                <li>Exklusiver Zugang zu Premium-Assets</li>
                <li>Persönliche Beratung durch unser Expertenteam</li>
                <li>Early Access zu neuen Plattform-Features</li>
                <li>Networking mit anderen Founders Circle Mitgliedern</li>
              </ul>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
              <a href="mailto:assero@assero.io" 
                 style="background: #c7a770; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block;">
                 📧 Kontakt aufnehmen
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px; color: #6c757d; font-size: 12px;">
            <p>Assero.io - Die Plattform für exklusive Asset-Investments</p>
            <p>Zeitstempel: ${timestamp}</p>
          </div>
        </div>
      `
    };
  },

  // Template for rejected applications
  rejected: (application) => {
    const timestamp = new Date().toLocaleString('de-DE');
    return {
      subject: '📝 Update zu Ihrer Founders Circle Bewerbung',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #6c757d, #495057); color: white; padding: 30px; text-align: center; border-radius: 12px 12px 0 0;">
            <h1 style="margin: 0; font-size: 28px;">📝 Bewerbungs-Update</h1>
            <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Ihre Bewerbung wurde geprüft</p>
          </div>
          
          <div style="background: #f8f9fa; padding: 30px; border-radius: 0 0 12px 12px; border: 1px solid #e9ecef;">
            <h2 style="color: #2c3e50; margin-top: 0;">Hallo ${application.first_name},</h2>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #6c757d;">
              <p style="margin: 0; color: #495057; font-weight: 600; font-size: 16px;">
                Vielen Dank für Ihr Interesse am Assero Founders Circle!
              </p>
            </div>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <p style="color: #555; line-height: 1.6; margin-bottom: 15px;">
                Nach sorgfältiger Prüfung Ihrer Bewerbung müssen wir Ihnen mitteilen, dass wir Ihre Aufnahme in den Founders Circle zum aktuellen Zeitpunkt nicht bestätigen können.
              </p>
              
              <h3 style="color: #2c3e50; margin-top: 20px;">💡 Konstruktives Feedback:</h3>
              <ul style="color: #555; line-height: 1.8;">
                <li>Der Founders Circle ist sehr exklusiv und auf spezifische Zielgruppen ausgerichtet</li>
                <li>Wir suchen nach etablierten Investoren und Unternehmern mit nachgewiesener Expertise</li>
                <li>Ihr Profil könnte in Zukunft besser zu unseren Kriterien passen</li>
              </ul>
            </div>
            
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #e9ecef;">
              <h3 style="color: #2c3e50; margin-top: 0;">🚀 Alternative Möglichkeiten:</h3>
              <ul style="color: #555; line-height: 1.8;">
                <li>Folgen Sie uns auf LinkedIn für Updates zu neuen Programmen</li>
                <li>Besuchen Sie unsere Website für allgemeine Plattform-Updates</li>
                <li>Kontaktieren Sie uns für individuelle Beratung</li>
              </ul>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
              <a href="mailto:assero@assero.io" 
                 style="background: #6c757d; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block;">
                 📧 Weitere Fragen?
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px; color: #6c757d; font-size: 12px;">
            <p>Assero.io - Die Plattform für exklusive Asset-Investments</p>
            <p>Zeitstempel: ${timestamp}</p>
          </div>
        </div>
      `
    };
  },

  // Template for new application notification (admin)
  newApplication: (application) => {
    const timestamp = new Date().toLocaleString('de-DE');
    return {
      subject: '🚀 Neue Founders Circle Bewerbung eingegangen!',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #c7a770, #2c3e50); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
            <h1 style="margin: 0; font-size: 24px;">🎯 Neue Founders Circle Bewerbung!</h1>
          </div>
          
          <div style="background: #f8f9fa; padding: 20px; border-radius: 0 0 8px 8px; border: 1px solid #e9ecef;">
            <h2 style="color: #2c3e50; margin-top: 0;">Bewerber Details:</h2>
            
            <div style="background: white; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #c7a770;">
              <p><strong>👤 Name:</strong> ${application.first_name} ${application.last_name}</p>
              <p><strong>📧 Email:</strong> ${application.email}</p>
              <p><strong>🏢 Firma:</strong> ${application.company || 'Nicht angegeben'}</p>
              <p><strong>💼 Rolle:</strong> ${application.role}</p>
            </div>
            
            <div style="background: white; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #3498db;">
              <h3 style="color: #2c3e50; margin-top: 0;">💭 Motivation:</h3>
              <p style="color: #555; line-height: 1.6;">${application.motivation}</p>
            </div>
            
            <div style="background: #e8f5e8; padding: 15px; border-radius: 6px; margin: 15px 0; border: 1px solid #c3e6c3;">
              <p style="margin: 0; color: #2d5a2d; font-weight: 600;">
                📊 Bewerbung wurde automatisch in Supabase gespeichert und wartet auf Ihre Prüfung.
              </p>
            </div>
            
            <div style="text-align: center; margin-top: 20px;">
              <a href="http://localhost:5173/admin" 
                 style="background: #c7a770; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 600;">
                 🔍 Bewerbung prüfen
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px; color: #6c757d; font-size: 12px;">
            <p>Diese Email wurde automatisch von Assero.io generiert.</p>
            <p>Zeitstempel: ${timestamp}</p>
          </div>
        </div>
      `
    };
  },

  // Template for status update notification (admin)
  statusUpdate: (application, oldStatus, newStatus) => {
    const timestamp = new Date().toLocaleString('de-DE');
    return {
      subject: `📝 Status-Update: ${application.first_name} ${application.last_name} - ${newStatus}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #17a2b8, #138496); color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
            <h1 style="margin: 0; font-size: 24px;">📝 Status-Update</h1>
          </div>
          
          <div style="background: #f8f9fa; padding: 20px; border-radius: 0 0 8px 8px; border: 1px solid #e9ecef;">
            <h2 style="color: #2c3e50; margin-top: 0;">Bewerbungsstatus geändert:</h2>
            
            <div style="background: white; padding: 15px; border-radius: 6px; margin: 10px 0; border-left: 4px solid #17a2b8;">
              <p><strong>👤 Bewerber:</strong> ${application.first_name} ${application.last_name}</p>
              <p><strong>📧 Email:</strong> ${application.email}</p>
              <p><strong>🔄 Status:</strong> ${oldStatus} → ${newStatus}</p>
              <p><strong>⏰ Zeitstempel:</strong> ${timestamp}</p>
            </div>
            
            <div style="background: #e8f5e8; padding: 15px; border-radius: 6px; margin: 15px 0; border: 1px solid #c3e6c3;">
              <p style="margin: 0; color: #2d5a2d; font-weight: 600;">
                ✅ Automatische Benachrichtigung an den Bewerber wurde gesendet.
              </p>
            </div>
            
            <div style="text-align: center; margin-top: 20px;">
              <a href="http://localhost:5173/admin" 
                 style="background: #17a2b8; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: 600;">
                 🔍 Dashboard öffnen
              </a>
            </div>
          </div>
          
          <div style="text-align: center; margin-top: 20px; color: #6c757d; font-size: 12px;">
            <p>Diese Email wurde automatisch von Assero.io generiert.</p>
          </div>
        </div>
      `
    };
  }
};

module.exports = emailTemplates;
