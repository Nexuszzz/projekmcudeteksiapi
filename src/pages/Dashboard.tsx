import { MetricCards } from '../components/MetricCards'
import { LiveChart } from '../components/LiveChart'
import { ControlPanel } from '../components/ControlPanel'
import { LogTable } from '../components/LogTable'
import { FireNotification } from '../components/FireNotification'
import FireDetectionGallery from '../components/FireDetectionGallery'

export default function Dashboard() {
  return (
    <>
      {/* Fire Alert Notifications */}
      <FireNotification />
      
      <main className="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Metric Cards */}
        <section className="mb-8">
          <MetricCards />
        </section>

        {/* Fire Detection Gallery */}
        <section className="mb-8">
          <FireDetectionGallery maxItems={20} />
        </section>

        {/* Chart and Control Panel */}
        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8 mb-8">
          <section className="xl:col-span-2">
            <LiveChart />
          </section>
          
          <section>
            <ControlPanel />
          </section>
        </div>

        {/* Log Table */}
        <section>
          <LogTable />
        </section>
      </main>
    </>
  )
}
